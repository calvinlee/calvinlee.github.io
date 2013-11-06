---
layout: post
title: "android\_get\_control\_socket"
category: Android
tags: [android, socket]
---

/hardware/ril/libril/ril.cpp下有如下代码：

    s_fdListen = android_get_control_socket(SOCKET_NAME_RIL);
    if (s_fdListen < 0) {
        LOGE("Failed to get socket '" SOCKET_NAME_RIL "'");
        exit(-1);
    }

    if (listen(s_fdListen, 4)) {
        exit(1);
    }
    s_fdCommand = accept(s_fdListen, (sockaddr *) &peeraddr, &socklen);

这个android\_get\_control\_socket函数有什么作用呢？
android\_get\_control\_socket函数定义在/system/core/include/cutils/sockets.h:

    #define ANDROID_SOCKET_ENV_PREFIX	"ANDROID_SOCKET_"
    #define ANDROID_SOCKET_DIR		"/dev/socket"

    #ifdef __cplusplus
    extern "C" {
    #endif

    /*
     * android_get_control_socket - simple helper function to get the file
     * descriptor of our init-managed Unix domain socket. `name' is the name of the
     * socket, as given in init.rc. Returns -1 on error.
     *
     * This is inline and not in libcutils proper because we want to use this in
     * third-party daemons with minimal modification.
     */
    static inline int android_get_control_socket(const char *name)
    {
    	char key[64] = ANDROID_SOCKET_ENV_PREFIX;
    	const char *val;
    	int fd;

    	/* build our environment variable, counting cycles like a wolf ... */
    #if HAVE_STRLCPY
    	strlcpy(key + sizeof(ANDROID_SOCKET_ENV_PREFIX) - 1,
    		name,
    		sizeof(key) - sizeof(ANDROID_SOCKET_ENV_PREFIX));
    #else	/* for the host, which may lack the almightly strncpy ... */
    	strncpy(key + sizeof(ANDROID_SOCKET_ENV_PREFIX) - 1,
    		name,
    		sizeof(key) - sizeof(ANDROID_SOCKET_ENV_PREFIX));
    	key[sizeof(key)-1] = '\0';
    #endif

    	val = getenv(key); // socket名字和对应的socket文件的文件描述符以键值对的形式存储在环境变量中， 
    	if (!val)
    		return -1;

    	errno = 0;
    	fd = strtol(val, NULL, 10);
    	if (errno)
    		return -1;

    	return fd;
    }

init.rc
/system/core/init/readme.txt


/system/core/init/util.c

    /*
     * create_socket - creates a Unix domain socket in ANDROID_SOCKET_DIR
     * ("/dev/socket") as dictated in init.rc. This socket is inherited by the
     * daemon. We communicate the file descriptor's value via the environment
     * variable ANDROID_SOCKET_ENV_PREFIX<name> ("ANDROID_SOCKET_foo").
     */
    int create_socket(const char *name, int type, mode_t perm, uid_t uid, gid_t gid)
    {
        struct sockaddr_un addr;
        int fd, ret;

        fd = socket(PF_UNIX, type, 0);
        if (fd < 0) {
            ERROR("Failed to open socket '%s': %s\n", name, strerror(errno));
            return -1;
        }

        memset(&addr, 0 , sizeof(addr));
        addr.sun_family = AF_UNIX;
        snprintf(addr.sun_path, sizeof(addr.sun_path), ANDROID_SOCKET_DIR"/%s",
                 name);

        ret = unlink(addr.sun_path);
        if (ret != 0 && errno != ENOENT) {
            ERROR("Failed to unlink old socket '%s': %s\n", name, strerror(errno));
            goto out_close;
        }

        ret = bind(fd, (struct sockaddr *) &addr, sizeof (addr));
        if (ret) {
            ERROR("Failed to bind socket '%s': %s\n", name, strerror(errno));
            goto out_unlink;
        }

        chown(addr.sun_path, uid, gid);
        chmod(addr.sun_path, perm);

        INFO("Created socket '%s' with mode '%o', user '%d', group '%d'\n",
             addr.sun_path, perm, uid, gid);

        return fd;

    out_unlink:
        unlink(addr.sun_path);
    out_close:
        close(fd);
        return -1;
    }

init.c

    static void publish_socket(const char *name, int fd)
    {
        char key[64] = ANDROID_SOCKET_ENV_PREFIX;
        char val[64];

        strlcpy(key + sizeof(ANDROID_SOCKET_ENV_PREFIX) - 1,
                name,
                sizeof(key) - sizeof(ANDROID_SOCKET_ENV_PREFIX));
        snprintf(val, sizeof(val), "%d", fd);
        add_environment(key, val); //添加到环境变量中

        /* make sure we don't close-on-exec */
        fcntl(fd, F_SETFD, 0);
    }
