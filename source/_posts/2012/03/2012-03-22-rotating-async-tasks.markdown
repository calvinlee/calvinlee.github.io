---
layout: post
title: "Rotating Async Tasks"
category: Android
tags: [android, 转载]
---

**Originally posted by [Even Charlton](http://evancharlton.com/thoughts/rotating-async-tasks).**

A common problem for new Android developers is how to handle screen rotations on the Android platform. Screen rotations cause all sorts of problems if you don't anticipate them because the Activity gets torn down completely and then rebuilt. If you don't handle it properly, AsyncTasks (threads) break completely. I'll show the code first and then talk about why it works. Here's the general pattern.

###The code

    public class MyActivity extends Activity {
        private MyTask mTask;
        @Override
        public void onCreate(Bundle savedInstanceState)
            super.onCreate(savedInstanceState)
            mTask = (MyTask) getLastNonConfigurationInstance();
            if(mTask == null) {
                mTask = new MyTask();
            }
            mTask.activity = this;
            if(mTask.getStatus() == AsyncTask.Status.PENDING) {
                mTask.execute();
            }
        }
        @Override
        public Object onRetainNonConfigurationInstance() {
            return mTask;
        }
        private static class MyTask extends AsyncTask<Params, Progress, Result>() {
            public MyActivity activity;
            @Override
            protected void onPreExecute() {
                // ...
            }
            @Override
            protected Result doInBackground(Params... params) {
                // ...
            }
            @Override
            protected void onProgressUpdate(Progress... updates) {
                // ...
            }
            @Override
            protected void onPostExecute(Result result) {
                // ...
            }
        }
    }

###The explanation
This works because MyTask is a static class--it will survive the class being torn down. All you then do is reattach it to the Activity when you recreate the Activity after the rotation. Note that you don't just always call mTask.execute() -- only call it if it hasn't been called before.

Of course this might not be perfect for your situation, but I assume that you can make the necessary modifications for your specific case. Feel free to drop me a line if you have any questions.

###注
从Api level 11开始引入了[Loader](http://developer.android.com/guide/topics/fundamentals/loaders.html)类，该类同AsyncTask一样可以实现异步加载，同时在设计上考虑了configuation改变的场景。
