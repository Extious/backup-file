#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/uaccess.h>
#include <linux/ioctl.h>

#define MY_DEVICE_MAJOR 111
#define MY_DEVICE_MINOR 0
#define MY_DEVICE_NAME "my_device"

#define IOCTL_CALC_SUM _IOR('c', 1, int)
#define IOCTL_CALC_DIFF _IOR('c', 2, int)
#define IOCTL_CALC_MAX _IOR('c', 3, int)

static int my_device_open(struct inode *inode, struct file *file);
static int my_device_release(struct inode *inode, struct file *file);
static ssize_t my_device_read(struct file *file, char __user *buf, size_t count, loff_t *ppos);
static ssize_t my_device_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos);
static long my_device_ioctl(struct file *file, unsigned int cmd, unsigned long arg);

static struct file_operations my_device_fops = {
    .owner = THIS_MODULE,
    .open = my_device_open,
    .release = my_device_release,
    .read = my_device_read,
    .write = my_device_write,
    .unlocked_ioctl = my_device_ioctl,
};

static dev_t my_device_dev;
static struct cdev my_device_cdev;

static int my_device_state = 0;
static int my_device_operand1 = 0;
static int my_device_operand2 = 0;

static int __init my_device_init(void)
{
    int ret;

    my_device_dev = MKDEV(MY_DEVICE_MAJOR, MY_DEVICE_MINOR);
    ret = register_chrdev_region(my_device_dev, 1, MY_DEVICE_NAME);
    if (ret < 0) {
        printk(KERN_WARNING "my_device: unable to register device\n");
        return ret;
    }

    cdev_init(&my_device_cdev, &my_device_fops);
    my_device_cdev.owner = THIS_MODULE;
    ret = cdev_add(&my_device_cdev, my_device_dev, 1);
    if (ret < 0) {
        printk(KERN_WARNING "my_device: unable to add device\n");
        unregister_chrdev_region(my_device_dev, 1);
        return ret;
    }

    return 0;
}

static void __exit my_device_exit(void)
{
    cdev_del(&my_device_cdev);
    unregister_chrdev_region(my_device_dev, 1);
}

module_init(my_device_init);
module_exit(my_device_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("A basic character device driver");

static int my_device_open(struct inode *inode, struct file *file)
{
    return 0;
}

static int my_device_release(struct inode *inode, struct file *file)
{
    return 0;
}

static ssize_t my_device_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
{
    if (copy_to_user(buf, &my_device_state, sizeof(my_device_state))) {
        return -EFAULT;
    }
    return sizeof(my_device_state);
}

static ssize_t my_device_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos)
{
    if (copy_from_user(&my_device_state, buf, sizeof(my_device_state))) {
        return -EFAULT;
    }
    return sizeof(my_device_state);
}

static long my_device_ioctl(struct file *file, unsigned int cmd, unsigned long arg1,unsigned long arg2)
{
	if (cmd==1)
	return arg1+arg2
}
