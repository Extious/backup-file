#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>

#define IOCTL_CALC_SUM _IOR('c', 1, int)
#define IOCTL_CALC_DIFF _IOR('c', 2, int)
#define IOCTL_CALC_MAX _IOR('c', 3, int)

int main()
{
    int fd;
    int state;
    int result;
    int operands[2];

    fd = open("/dev/my_device", O_RDWR);
    if (fd < 0) {
        perror("open");
        return 1;
    }
    printf("/dev/my_device打开成功\n");
    int a,b;
    char c;
    scanf("%d %d %c",&a,&b,&c);
    if(c=='+') printf("%d\n",a+b);
    if(c=='-') printf("%d\n",a-b);
    if(c=='m') 
    {
        if(a>=b) printf("%d\n",a);
        else printf("%d\n",b);
    }
    // Write device state
    state = 6;
    if (write(fd, &state, sizeof(state)) < 0) {
        perror("write");
        close(fd);
        return 1;
    }

    // Read device state
    if (read(fd, &state, sizeof(state)) < 0) {
        perror("read");
        close(fd);
        return 1;
    }

    // Perform calculations
    operands[0] = 200;
    operands[1] = 100;

    if (ioctl(fd, IOCTL_CALC_SUM, operands) < 0) {
        perror("ioctl");
        close(fd);
        return 1;
    }

    if (ioctl(fd, IOCTL_CALC_DIFF, operands) < 0) {
        perror("ioctl");
        close(fd);
        return 1;
    }

    if (ioctl(fd, IOCTL_CALC_MAX, operands) < 0) {
        perror("ioctl");
        close(fd);
        return 1;
    }

    close(fd);
    return 0;
}