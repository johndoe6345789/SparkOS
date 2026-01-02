/*
 * SparkOS Init - Minimal init system for SparkOS
 * This is the first process that runs after the kernel boots
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/reboot.h>
#include <signal.h>
#include <errno.h>
#include <string.h>

static void signal_handler(int sig) {
    if (sig == SIGCHLD) {
        // Reap zombie processes
        while (waitpid(-1, NULL, WNOHANG) > 0);
    }
}

static void spawn_gui() {
    pid_t pid = fork();
    
    if (pid < 0) {
        perror("fork failed");
        return;
    }
    
    if (pid == 0) {
        // Child process - exec Qt6 GUI application as root (no user switching)
        
        char *argv[] = {"/usr/bin/sparkos-gui", NULL};
        char *envp[] = {
            "HOME=/root",
            "PATH=/bin:/sbin:/usr/bin:/usr/sbin",
            "QT_QPA_PLATFORM=linuxfb:fb=/dev/fb0",
            "QT_QPA_FB_FORCE_FULLSCREEN=1",
            "QT_QPA_FONTDIR=/usr/share/fonts",
            NULL
        };
        
        execve("/usr/bin/sparkos-gui", argv, envp);
        
        perror("failed to exec GUI application");
        exit(1);
    }
    
    // Parent process - wait for GUI to exit
    int status;
    waitpid(pid, &status, 0);
}

static void spawn_shell() {
    pid_t pid = fork();
    
    if (pid < 0) {
        perror("fork failed");
        return;
    }
    
    if (pid == 0) {
        // Child process - exec shell as root (fallback only)
        
        char *argv[] = {"/bin/sh", "-l", NULL};
        char *envp[] = {
            "HOME=/root",
            "PATH=/bin:/sbin:/usr/bin:/usr/sbin",
            "TERM=linux",
            "PS1=SparkOS# ",
            NULL
        };
        
        execve("/bin/sh", argv, envp);
        
        perror("failed to exec shell");
        exit(1);
    }
    
    // Parent process - wait for shell to exit
    int status;
    waitpid(pid, &status, 0);
}

int main(int argc, char *argv[]) {
    printf("SparkOS Init System Starting...\n");
    
    // Make sure we're PID 1
    if (getpid() != 1) {
        fprintf(stderr, "init must be run as PID 1\n");
        return 1;
    }
    
    // Set up signal handlers
    signal(SIGCHLD, signal_handler);
    
    // Mount essential filesystems
    printf("Mounting essential filesystems...\n");
    if (system("mount -t proc proc /proc 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Failed to mount /proc\n");
    }
    if (system("mount -t sysfs sys /sys 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Failed to mount /sys\n");
    }
    if (system("mount -t devtmpfs dev /dev 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Failed to mount /dev\n");
    }
    if (system("mount -t tmpfs tmpfs /tmp 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Failed to mount /tmp\n");
    }
    
    // Set up overlay filesystem for immutable base OS
    printf("Setting up overlay filesystem for writable layer...\n");
    
    // Create overlay directories in tmpfs
    if (system("mkdir -p /tmp/overlay/var-upper /tmp/overlay/var-work 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Failed to create overlay directories for /var\n");
    }
    
    // Mount overlay on /var for logs and runtime data
    if (system("mount -t overlay overlay -o lowerdir=/var,upperdir=/tmp/overlay/var-upper,workdir=/tmp/overlay/var-work /var 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Failed to mount overlay on /var - system may be read-only\n");
    } else {
        printf("Overlay filesystem mounted on /var (base OS is immutable)\n");
    }
    
    // Mount tmpfs on /run for runtime data
    if (system("mkdir -p /run 2>/dev/null") == 0) {
        if (system("mount -t tmpfs tmpfs /run 2>/dev/null") != 0) {
            fprintf(stderr, "Warning: Failed to mount /run\n");
        }
    }
    
    // Initialize network (wired only for bootstrap)
    printf("Initializing wired network...\n");
    if (system("/sbin/init-network 2>/dev/null") != 0) {
        fprintf(stderr, "Warning: Network initialization failed - check network interface availability\n");
    }
    
    printf("Starting Qt6 GUI application...\n");
    printf("Welcome to SparkOS!\n");
    printf("===================\n");
    printf("Base OS: Read-only (immutable)\n");
    printf("Writable: /tmp, /var (overlay), /run\n");
    printf("Mode: Qt6 GUI (Network-First Architecture)\n");
    printf("No Users/Authentication - Direct Boot to GUI\n\n");
    
    // Main loop - keep respawning GUI application
    while (1) {
        spawn_gui();
        
        // If GUI exits, respawn after a short delay
        printf("\nGUI application exited. Restarting in 2 seconds...\n");
        sleep(2);
    }
    
    return 0;
}
