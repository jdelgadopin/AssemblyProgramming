%ifidni __OUTPUT_FORMAT__, win64
%define WINDOWS
%endif
%ifidni __OUTPUT_FORMAT__,macho64
%macro defaultrel  0.nolist
        default  rel
%endmacro
%define main _main
%macro cname 1-*
%rep %0
%define %1 _ %+ %1
%rotate 1
%endrep
%endmacro
%macro CNAME 1-*
%rep %0
%define %1 _ %+ %1
%rotate 1
%endrep
%endmacro
%define abort _ %+ abort
%define abs _ %+ abs
%define acos _ %+ acos
%define alarm _ %+ alarm
%define alloca _ %+ alloca
%define asctime _ %+ asctime
%define asin _ %+ asin
%define atan _ %+ atan
%define atexit _ %+ atexit
%define atof _ %+ atof
%define atoi _ %+ atoi
%define atol _ %+ atol
%define basename _ %+ basename
%define bcmp _ %+ bcmp
%define bcopy _ %+ bcopy
%define break _ %+ break
%define brk _ %+ brk
%define bsearch _ %+ bsearch
%define bzero _ %+ bzero
%define calloc _ %+ calloc
%define ceil _ %+ ceil
%define ceilf _ %+ ceilf
%define chdir _ %+ chdir
%define chmod _ %+ chmod
%define chown _ %+ chown
%define chroot _ %+ chroot
%define clearenv _ %+ clearenv
%define clock _ %+ clock
%define close _ %+ close
%define closedir _ %+ closedir
%define cos _ %+ cos
%define creat _ %+ creat
%define ctime _ %+ ctime
%define cuserid _ %+ cuserid
%define difftime _ %+ difftime
%define dirname _ %+ dirname
%define drand48 _ %+ drand48
%define dup _ %+ dup
%define dup2 _ %+ dup2
%define dup3 _ %+ dup3
%define erf _ %+ erf
%define errno _ %+ errno
%define exec _ %+ exec
%define execl _ %+ execl
%define execle _ %+ execle
%define execlp _ %+ execlp
%define execv _ %+ execv
%define execve _ %+ execve
%define execvp _ %+ execvp
%define execvpe _ %+ execvpe
%define exit _ %+ exit
%define exp _ %+ exp
%define fclose _ %+ fclose
%define fcntl _ %+ fcntl
%define fdopen _ %+ fdopen
%define fdopendir _ %+ fdopendir
%define feof _ %+ feof
%define fflush _ %+ fflush
%define fgetc _ %+ fgetc
%define fgets _ %+ fgets
%define fileno _ %+ fileno
%define flock _ %+ flock
%define floor _ %+ floor
%define fopen _ %+ fopen
%define fork _ %+ fork
%define fprintf _ %+ fprintf
%define fputc _ %+ fputc
%define fputs _ %+ fputs
%define fread _ %+ fread
%define free _ %+ free
%define freopen _ %+ freopen
%define fscanf _ %+ fscanf
%define fseek _ %+ fseek
%define fsetpos _ %+ fsetpos
%define fstat _ %+ fstat
%define fsync _ %+ fsync
%define ftell _ %+ ftell
%define ftime _ %+ ftime
%define ftok _ %+ ftok
%define funlockfile _ %+ funlockfile
%define getc _ %+ getc
%define getchar _ %+ getchar
%define get_current_dir_name _ %+ get_current_dir_name
%define getcwd _ %+ getcwd
%define getdate _ %+ getdate
%define getegid _ %+ getegid
%define getenv _ %+ getenv
%define geteuid _ %+ geteuid
%define getgid _ %+ getgid
%define getgrgid _ %+ getgrgid
%define getgrnam _ %+ getgrnam
%define getgroups _ %+ getgroups
%define getline _ %+ getline
%define getopt _ %+ getopt
%define getpagesize _ %+ getpagesize
%define getpass _ %+ getpass
%define getpgid _ %+ getpgid
%define getpgrp _ %+ getpgrp
%define getpid _ %+ getpid
%define getpmsg _ %+ getpmsg
%define getppid _ %+ getppid
%define getpt _ %+ getpt
%define getpw _ %+ getpw
%define getpwent _ %+ getpwent
%define getpwnam _ %+ getpwnam
%define getpwuid _ %+ getpwuid
%define gets _ %+ gets
%define getsid _ %+ getsid
%define gettimeofday _ %+ gettimeofday
%define getuid _ %+ getuid
%define getumask _ %+ getumask
%define getwd _ %+ getwd
%define glob _ %+ glob
%define globfree _ %+ globfree
%define gmtime _ %+ gmtime
%define index _ %+ index
%define ioctl _ %+ ioctl
%define ioperm _ %+ ioperm
%define kill _ %+ kill
%define killpg _ %+ killpg
%define link _ %+ link
%define localtime _ %+ localtime
%define lock _ %+ lock
%define lockf _ %+ lockf
%define lseek _ %+ lseek
%define lstat _ %+ lstat
%define malloc _ %+ malloc
%define memccpy _ %+ memccpy
%define memchr _ %+ memchr
%define memcmp _ %+ memcmp
%define memcpy _ %+ memcpy
%define memfrob _ %+ memfrob
%define memmem _ %+ memmem
%define memmove _ %+ memmove
%define mempcpy _ %+ mempcpy
%define memrchr _ %+ memrchr
%define memset _ %+ memset
%define mkdir _ %+ mkdir
%define mkdtemp _ %+ mkdtemp
%define mkfifo _ %+ mkfifo
%define mknod _ %+ mknod
%define mktemp _ %+ mktemp
%define mktime _ %+ mktime
%define mlock _ %+ mlock
%define mlockall _ %+ mlockall
%define mmap _ %+ mmap
%define nanosleep _ %+ nanosleep
%define nice _ %+ nice
%define on_exit _ %+ on_exit
%define open _ %+ open
%define opendir _ %+ opendir
%define optarg _ %+ optarg
%define opterr _ %+ opterr
%define optind _ %+ optind
%define optopt _ %+ optopt
%define pause _ %+ pause
%define perror _ %+ perror
%define pipe _ %+ pipe
%define pipe2 _ %+ pipe2
%define popen _ %+ popen
%define pow _ %+ pow
%define printf _ %+ printf
%define pthread_attr_destroy _ %+ pthread_attr_destroy
%define pthread_attr_getaffinity_np _ %+ pthread_attr_getaffinity_np
%define pthread_attr_getdetachstate _ %+ pthread_attr_getdetachstate
%define pthread_attr_getguardsize _ %+ pthread_attr_getguardsize
%define pthread_attr_getinheritsched _ %+ pthread_attr_getinheritsched
%define pthread_attr_getschedparam _ %+ pthread_attr_getschedparam
%define pthread_attr_getschedpolicy _ %+ pthread_attr_getschedpolicy
%define pthread_attr_getscope _ %+ pthread_attr_getscope
%define pthread_attr_getstack _ %+ pthread_attr_getstack
%define pthread_attr_getstackaddr _ %+ pthread_attr_getstackaddr
%define pthread_attr_getstacksize _ %+ pthread_attr_getstacksize
%define pthread_attr_init _ %+ pthread_attr_init
%define pthread_attr_setaffinity_np _ %+ pthread_attr_setaffinity_np
%define pthread_attr_setdetachstate _ %+ pthread_attr_setdetachstate
%define pthread_attr_setguardsize _ %+ pthread_attr_setguardsize
%define pthread_attr_setinheritsched _ %+ pthread_attr_setinheritsched
%define pthread_attr_setschedparam _ %+ pthread_attr_setschedparam
%define pthread_attr_setschedpolicy _ %+ pthread_attr_setschedpolicy
%define pthread_attr_setscope _ %+ pthread_attr_setscope
%define pthread_attr_setstack _ %+ pthread_attr_setstack
%define pthread_attr_setstackaddr _ %+ pthread_attr_setstackaddr
%define pthread_attr_setstacksize _ %+ pthread_attr_setstacksize
%define pthread_cancel _ %+ pthread_cancel
%define pthread_cleanup_pop _ %+ pthread_cleanup_pop
%define pthread_cleanup_pop_restore_np _ %+ pthread_cleanup_pop_restore_np
%define pthread_cleanup_push _ %+ pthread_cleanup_push
%define pthread_cleanup_push_defer_np _ %+ pthread_cleanup_push_defer_np
%define pthread_create _ %+ pthread_create
%define pthread_detach _ %+ pthread_detach
%define pthread_equal _ %+ pthread_equal
%define pthread_exit _ %+ pthread_exit
%define pthread_getaffinity_np _ %+ pthread_getaffinity_np
%define pthread_getattr_np _ %+ pthread_getattr_np
%define pthread_getconcurrency _ %+ pthread_getconcurrency
%define pthread_getcpuclockid _ %+ pthread_getcpuclockid
%define pthread_getschedparam _ %+ pthread_getschedparam
%define pthread_join _ %+ pthread_join
%define pthread_kill _ %+ pthread_kill
%define pthread_kill_other_threads_np _ %+ pthread_kill_other_threads_np
%define pthread_self _ %+ pthread_self
%define pthread_setaffinity_np _ %+ pthread_setaffinity_np
%define pthread_setcancelstate _ %+ pthread_setcancelstate
%define pthread_setcanceltype _ %+ pthread_setcanceltype
%define pthread_setconcurrency _ %+ pthread_setconcurrency
%define pthread_setschedparam _ %+ pthread_setschedparam
%define pthread_setschedprio _ %+ pthread_setschedprio
%define pthread_sigmask _ %+ pthread_sigmask
%define pthread_sigqueue _ %+ pthread_sigqueue
%define pthread_testcancel _ %+ pthread_testcancel
%define pthread_timedjoin_np _ %+ pthread_timedjoin_np
%define pthread_tryjoin_np _ %+ pthread_tryjoin_np
%define pthread_yield _ %+ pthread_yield
%define putc _ %+ putc
%define putchar _ %+ putchar
%define putenv _ %+ putenv
%define puts _ %+ puts
%define qsort _ %+ qsort
%define raise _ %+ raise
%define rand _ %+ rand
%define random _ %+ random
%define read _ %+ read
%define readahead _ %+ readahead
%define readdir _ %+ readdir
%define readline _ %+ readline
%define realloc _ %+ realloc
%define remove _ %+ remove
%define rename _ %+ rename
%define rewind _ %+ rewind
%define rewinddir _ %+ rewinddir
%define rindex _ %+ rindex
%define rmdir _ %+ rmdir
%define sbrk _ %+ sbrk
%define scandir _ %+ scandir
%define scanf _ %+ scanf
%define seed48 _ %+ seed48
%define seekdir _ %+ seekdir
%define setbuf _ %+ setbuf
%define setbuffer _ %+ setbuffer
%define setegid _ %+ setegid
%define setenv _ %+ setenv
%define seteuid _ %+ seteuid
%define setgid _ %+ setgid
%define setgroups _ %+ setgroups
%define setjmp _ %+ setjmp
%define setlinebuf _ %+ setlinebuf
%define setpgid _ %+ setpgid
%define setpgrp _ %+ setpgrp
%define setregid _ %+ setregid
%define setresgid _ %+ setresgid
%define setresuid _ %+ setresuid
%define setreuid _ %+ setreuid
%define setsid _ %+ setsid
%define setuid _ %+ setuid
%define setvbuf _ %+ setvbuf
%define signal _ %+ signal
%define sin _ %+ sin
%define sincos _ %+ sincos
%define sleep _ %+ sleep
%define snprintf _ %+ snprintf
%define sprintf _ %+ sprintf
%define sqrt _ %+ sqrt
%define srand _ %+ srand
%define srand48 _ %+ srand48
%define srandom _ %+ srandom
%define sscanf _ %+ sscanf
%define stat _ %+ stat
%define statfs _ %+ statfs
%define stderr _ %+ stderr
%define stdin _ %+ stdin
%define stdout _ %+ stdout
%define stpcpy _ %+ stpcpy
%define stpncpy _ %+ stpncpy
%define strcasecmp _ %+ strcasecmp
%define strcasestr _ %+ strcasestr
%define strcat _ %+ strcat
%define strchr _ %+ strchr
%define strchrnul _ %+ strchrnul
%define strcmp _ %+ strcmp
%define strcoll _ %+ strcoll
%define strcpy _ %+ strcpy
%define strcspn _ %+ strcspn
%define strdup _ %+ strdup
%define strdupa _ %+ strdupa
%define strerror _ %+ strerror
%define strfry _ %+ strfry
%define strftime _ %+ strftime
%define strlen _ %+ strlen
%define strncasecmp _ %+ strncasecmp
%define strncat _ %+ strncat
%define strncmp _ %+ strncmp
%define strncpy _ %+ strncpy
%define strndup _ %+ strndup
%define strndupa _ %+ strndupa
%define strnlen _ %+ strnlen
%define strpbrk _ %+ strpbrk
%define strptime _ %+ strptime
%define strrchr _ %+ strrchr
%define strsep _ %+ strsep
%define strsignal _ %+ strsignal
%define strspn _ %+ strspn
%define strstr _ %+ strstr
%define strtod _ %+ strtod
%define strtof _ %+ strtof
%define strtoimax _ %+ strtoimax
%define strtok _ %+ strtok
%define strtol _ %+ strtol
%define strtold _ %+ strtold
%define strtoul _ %+ strtoul
%define swab _ %+ swab
%define symlink _ %+ symlink
%define sync _ %+ sync
%define sysctl _ %+ sysctl
%define system _ %+ system
%define tan _ %+ tan
%define telldir _ %+ telldir
%define tempnam _ %+ tempnam
%define time _ %+ time
%define timegm _ %+ timegm
%define timelocal _ %+ timelocal
%define tmpfile _ %+ tmpfile
%define tmpnam _ %+ tmpnam
%define ulimit _ %+ ulimit
%define umask _ %+ umask
%define ungetc _ %+ ungetc
%define unlink _ %+ unlink
%define unsetenv _ %+ unsetenv
%define usleep _ %+ usleep
%define ustat _ %+ ustat
%define utime _ %+ utime
%define utimes _ %+ utimes
%define valloc _ %+ valloc
%define vasprintf _ %+ vasprintf
%define vfork _ %+ vfork
%define vfprintf _ %+ vfprintf
%define vfscanf _ %+ vfscanf
%define vprintf _ %+ vprintf
%define vscanf _ %+ vscanf
%define vserver _ %+ vserver
%define vsnprintf _ %+ vsnprintf
%define vsprintf _ %+ vsprintf
%define vsscanf _ %+ vsscanf
%define wait _ %+ wait
%define wait3 _ %+ wait3
%define wait4 _ %+ wait4
%define waitid _ %+ waitid
%define waitpid _ %+ waitpid
%define write _ %+ write
%else
%define start _start
%macro cname 1-*
%rep %0
%undef %1
%rotate 1
%endrep
%endmacro
%macro CNAME 1-*
%rep %0
%undef %1
%rotate 1
%endrep
%endmacro
%macro defaultrel  0.nolist
%endmacro
%endif
    defaultrel
%undef defaultrel

%ifdef WINDOWS
;
;   frame  [parameters] [locals] [new_parameters]
;   parameters > 4 on stack
;
%macro frame 0-3 0,0,0   ; %1, %2 & %3 default to 0 
%if %3 <= 4
%assign xp 0
%else
%assign xp %3-4
%endif
%if %2 <= 4
%assign locals 0
%else
%assign locals %2-4
%endif
;   Subtract enough for locals and then parameters past 6
%assign frame_size (4+locals+xp+1)/2*16
%endmacro
%undef xp
%undef locals

;   Windows
;   First 4 local variables are in the stack frame

local1 equ 16
local2 equ 24
local3 equ 32
local4 equ 40

;   Local variables after 4 relative to rbp with negative offsets
;
;   local5 will be -8
;   local6 will be -16
;   ...
;   local100 be be -768
;   [rbp+localX]

%macro local 1
local%1 equ   -8*(%1-4)
%endmacro
%assign i 5
%rep 100
     local i
     %assign i i+1
%endrep
%undef i   
;   Windows
;   Where to place extra parameters when you call a function with
;   more than 4 parameters.
;
;   newPar5 will be 32
;   newPar6 will be 40
;   ...
;   newPar100 will be 99*8 = 792
;   [rsp+newParX]

%macro newpar 1
newPar%1  equ   8*(i-1)
%endmacro
%assign i 5
%rep 96
        newpar i
        %assign i i+1
%endrep
%undef i   

;   Windows
;   Where to find additional parameters to current function
;   past parameter 4
;
;   currPar5 will be 48
;   currPar6 will be 56
;   ...
;   currPar100 will be 808
;   [rbp+currParX]

%macro parequ 1
currPar%1  equ 16+8*(%1+1)
%endmacro

%assign i 5
%rep 96
        parequ i
        %assign i i+1
%endrep
%undef i   

%else                       ; Linux/OS X
;
;   frame [parameters] [locals] [new_parameters]
;   parameters > 6 on stack
;
%macro frame 0-3 0,0,0
%if %3 <= 6
%assign xp 0
%else
%assign xp %3-6
%endif
;   Subtract enough for locals and then parameters past 6
%assign frame_size (%2+xp+1)/2*16
%endmacro
%undef xp

;   Linux
;   Local variables accessed relative to rbp with negative offsets
;
;   local1 will be -8
;   local2 will be -16
;   ...
;   local100 be be -800
;   [rbp+localX]

%macro local 1
local%1 equ   -8*%1
%endmacro
%assign i 1
%rep 100
     local i
     %assign i i+1
%endrep
%undef i
   
;   Linux
;   Where to place extra parameters when you call a function with
;   more than 6 parameters.
;
;   newPar7 will be 0
;   newPar8 will be 8
;   ...
;   newPar100 will be 93*8 = 744
;   [rsp+newParX]

%macro newpar 1
newPar%1  equ   8*(i-7)
%endmacro
%assign i 7
%rep 94
        newpar i
        %assign i i+1
%endrep
%undef i

;   Linux
;   Where to find additional parameters to current function
;   past parameter 6
;
;   currPar7 will be 16
;   currPar8 will be 24
;   ...
;   currPar100 will be 760
;   [rbp+currParX]

%macro parequ 1
currPar%1  equ 16+8*(%1-7)
%endmacro

%assign i 7
%rep 94
        parequ i
        %assign i i+1
%endrep
%undef i

%endif      ; from original test on WINDOWS

%macro  multipush 2-*
%rep %0
        push %1
%rotate 1
%endrep
%endmacro

%macro  multipop 2-*
%rep %0
        pop %1
%rotate 1
%endrep
%endmacro

%define raxd eax
%define raxw ax
%define raxb al
%define raxh ah

%define rbxd ebx
%define rbxw bx
%define rbxb bl
%define rbxh bh

%define rcxd ecx
%define rcxw cx
%define rcxb cl
%define rcxh ch

%define rdxd edx
%define rdxw dx
%define rdxb dl
%define rdxh dh

%define rdid edi
%define rdiw di
%define rdib dil

%define rsid six
%define rsiw si
%define rsib sil

%define rbpd ebp
%define rbpw bp

%macro alias 2
%define q%1 %2
%define d%1 %2d
%define w%1 %2w
%define b%1 %2b
%define h%1 %2h
%endmacro

%macro unalias 1-*
%rep %0
%undef q%1
%undef d%1
%undef w%1
%undef b%1
%undef h%1
%rotate 1
%endrep
%endmacro

%macro fpalias 2
%define y%1 ymm%2
%define x%1 xmm%2
%endmacro

%macro fpunalias 1-*
%rep %0
%undef y%1
%undef x%1
%rotate 1
%endrep
%endmacro
