---
layout: post
title: "Java的四种引用类型"
category: Java
tags: [java, todo]
---

Java中有四种引用类型，按其引用强度由强到弱依次为：  
    Strong reference > Soft reference > Weak reference > Phantom reference

###Strong reference
最常用的为strong reference，就是说只要某个对象还被一个强引用引用着，那么GC就不会回收它。使用强引用的一个弊端就是有可能引起内存泄漏。比如有一个hashmap集合，用来存储对象引用，如果你忘了在某个时机把这些元素remove掉，那么这些对象就会在这个hashmap的生命周期内被一直引用而不能被GC回收，更糟糕的是，如果这个对象体积很大，而又如果这个hashmap被声明为static的，那么随着程序的运行，内存总有被撑爆的那一刻。

###Soft reference
而soft reference 就不同了，在内存资源极度紧张的情况下，GC会将被Soft reference 引用的对象回收以释放内存空间。这个特性非常适合用来做cache：在内存资源充裕的情况下，它和强引用一样，GC不会回收它，而在内存紧张的情况下，GC实在找不到更多可用的空间的情况下，Soft reference的对象会被回收掉。  
以下代码展示了基于Soft reference的缓存类的使用：

    /*
     * Copyright (C) 2009 The Android Open Source Project
     *
     * Licensed under the Apache License, Version 2.0 (the "License");
     * you may not use this file except in compliance with the License.
     * You may obtain a copy of the License at
     *
     *      http://www.apache.org/licenses/LICENSE-2.0
     *
     * Unless required by applicable law or agreed to in writing, software
     * distributed under the License is distributed on an "AS IS" BASIS,
     * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     * See the License for the specific language governing permissions and
     * limitations under the License
     */

    package com.android.providers.contacts;

    import com.android.providers.contacts.ContactsDatabaseHelper.NicknameLookupColumns;
    import com.android.providers.contacts.ContactsDatabaseHelper.Tables;
    import com.google.android.collect.Maps;

    import android.database.Cursor;
    import android.database.sqlite.SQLiteDatabase;

    import java.lang.ref.SoftReference;
    import java.util.BitSet;
    import java.util.HashMap;


    /**
     * Cache for common nicknames.
     */
    public class CommonNicknameCache  {

        // We will use this much memory (in bits) to optimize the nickname cluster lookup
        private static final int NICKNAME_BLOOM_FILTER_SIZE = 0x1FFF;   // =long[128]
        private BitSet mNicknameBloomFilter;

        private HashMap<String, SoftReference<String[]>> mNicknameClusterCache = Maps.newHashMap();

        private final SQLiteDatabase mDb;

        public CommonNicknameCache(SQLiteDatabase db) {
            mDb = db;
        }

        private final static class NicknameLookupPreloadQuery {
            public final static String TABLE = Tables.NICKNAME_LOOKUP;

            public final static String[] COLUMNS = new String[] {
                NicknameLookupColumns.NAME
            };

            public final static int NAME = 0;
        }

        /**
         * Read all known common nicknames from the database and populate a Bloom
         * filter using the corresponding hash codes. The idea is to eliminate most
         * of unnecessary database lookups for nicknames. Given a name, we will take
         * its hash code and see if it is set in the Bloom filter. If not, we will know
         * that the name is not in the database. If it is, we still need to run a
         * query.
         * <p>
         * Given the size of the filter and the expected size of the nickname table,
         * we should expect the combination of the Bloom filter and cache will
         * prevent around 98-99% of unnecessary queries from running.
         */
        private void preloadNicknameBloomFilter() {
        	// 这个filter被设计成一个简化的hash表（没有处理hash冲突的情况，实际上也没有必要）
            mNicknameBloomFilter = new BitSet(NICKNAME_BLOOM_FILTER_SIZE + 1);
            Cursor cursor = mDb.query(NicknameLookupPreloadQuery.TABLE,
                    NicknameLookupPreloadQuery.COLUMNS,
                    null, null, null, null, null);
            try {
                int count = cursor.getCount();
                for (int i = 0; i < count; i++) {
                    cursor.moveToNext();
                    String normalizedName = cursor.getString(NicknameLookupPreloadQuery.NAME);
                    int hashCode = normalizedName.hashCode();
                    // 将元素put进hash表（有可能冲突），参见HashMap的put实现
                    // 和hashcode做与运算的这个值必须是“hash表长度-1”
                    mNicknameBloomFilter.set(hashCode & NICKNAME_BLOOM_FILTER_SIZE);
                }
            } finally {
                cursor.close();
            }
        }

        /**
         * Returns nickname cluster IDs or null. Maintains cache.
         */
        protected String[] getCommonNicknameClusters(String normalizedName) {
            if (mNicknameBloomFilter == null) {
                preloadNicknameBloomFilter();
            }

            int hashCode = normalizedName.hashCode();

    		// 如果没有找到，说明cache中**一定**不存在这个key所对应的值;
            // 如果找到了，说明cache中**可能**存在这个key对应的值，需要进一步到cache中查找
    		if (!mNicknameBloomFilter.get(hashCode & NICKNAME_BLOOM_FILTER_SIZE)) {
    			return null;
    		}

            SoftReference<String[]> ref;
            String[] clusters = null;

            // 注意：这里需要同步对cache的访问
            synchronized (mNicknameClusterCache) {
                if (mNicknameClusterCache.containsKey(normalizedName)) {
                    ref = mNicknameClusterCache.get(normalizedName);
                    if (ref == null) {
                        return null;
                    }
                    clusters = ref.get();
                }
            }

            // 没有命中，这时才需要到DB中加载，并加入cache
            if (clusters == null) {
                clusters = loadNicknameClusters(normalizedName);
                ref = clusters == null ? null : new SoftReference<String[]>(clusters);
                synchronized (mNicknameClusterCache) {
                    mNicknameClusterCache.put(normalizedName, ref);
                }
            }
            return clusters;
        }

        private interface NicknameLookupQuery {
            String TABLE = Tables.NICKNAME_LOOKUP;

            String[] COLUMNS = new String[] {
                NicknameLookupColumns.CLUSTER
            };

            int CLUSTER = 0;
        }

        protected String[] loadNicknameClusters(String normalizedName) {
            String[] clusters = null;
            Cursor cursor = mDb.query(NicknameLookupQuery.TABLE, NicknameLookupQuery.COLUMNS,
                    NicknameLookupColumns.NAME + "=?", new String[] { normalizedName },
                    null, null, null);
            try {
                int count = cursor.getCount();
                if (count > 0) {
                    clusters = new String[count];
                    for (int i = 0; i < count; i++) {
                        cursor.moveToNext();
                        clusters[i] = cursor.getString(NicknameLookupQuery.CLUSTER);
                    }
                }
            } finally {
                cursor.close();
            }
            return clusters;
        }
    }

这个缓存类实现的实际上是一个二级缓存：

1. 第一级是一个BitSet，实现为一个hash表，它充当了一个过滤器的作用。第一次加载时会从db中查找所有的数据，并通过hash算法插入到表中的适当位置，这个过程和HashMap的实现是一样的，只不过没有处理hash冲突的情况，当出现hash冲突时，会覆盖表中原有的值。
1. 第二级是一个HashMap，是真正的cache。其中的元素通过SoftReference引用。

###Weak reference
Weak reference和Soft reference类似，区别在于一旦GC启动，被Weak reference引用的对象就会被回收，而不管当前内存资源是否充裕，因此，被Weak reference引用的对象具有更短的生命周期。但是，由于gc是一个优先级比较低的进程，Weak reference的对象不会像你想象中那么快就被回收了。

###Phantom reference
Phantom reference 和以上几种引用都不同。它的`get()`方法永远都会返回null。那么它究竟有什么作用呢？  
TODO...

###References
* <http://weblogs.java.net/blog/enicholas/archive/2006/05/understanding_w.html>
* <http://improving.iteye.com/blog/436311>

