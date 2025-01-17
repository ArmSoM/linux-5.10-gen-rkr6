# RK3588编译&烧录Linux固件

## 1、开发环境及工具准备

Rockchip Linux 软件包：linux-5.10-gen-rkr6

主机：

- 安装VMware搭建虚拟机，版本为Ubuntu 20.04 (硬盘容量大于100G）

- 安装远程连接工具MobaXterm（可连接虚拟机方便文件传输）


## 2、SDK编译环境搭建

### 2.1、安装库和工具集：

```shell
sudo apt-get install git ssh make gcc libssl-dev liblz4-tool expect g++ patchelf chrpath gawk texinfo chrpath diffstat binfmt-support qemu-user-static live-build bison flex fakeroot cmake gcc-multilib g++-multilib unzip device-tree-compiler ncurses-dev libgucharmap-2-90-dev bzip2 expat gpgv2 cpp-aarch64-linux-gnu time mtd-utils
```

### 2.2、克隆项目

```
git clone 
```

### 2.5、检查和升级软件包

- 检查make版本(要求make 4.0及以上版本）
```
make -v
GNU Make 4.2
Built for x86_64-pc-linux-gnu
```

- 升级make版本
```
git clone https://github.com/mirror/make.git
cd make
git checkout 4.2
git am $BUILDROOT_DIR/package/make/*.patch
autoreconf -f -i
./configure
make make -j8
sudo install -m 0755 make /usr/bin/make
```


- 检查lz4版本（要求安装 lz4 1.7.3及以上版本）
```
lz4 -v
*** LZ4 command line interface 64-bits v1.9.4, by Yann Collet ***
refusing to read from a console
```

- 升级lz4版本
```
git clone https://github.com/lz4/lz4.git
cd lz4
make
sudo make install
sudo install -m 0755 lz4 /usr/bin/lz4
```


- 检查和升级git版本
```
git clone https://github.com/mirror/make.git --depth 1 -b 4.2
cd make
git am $BUILDROOT_DIR/package/make/*.patch
autoreconf -f -i
./configure
make make -j8
install -m 0755 make /usr/local/bin/make
```
### 2.6、debian 环境

解决 mv:cannot stat'chroot.files': No such file or directory 问题

```
cd debian
sudo apt-get install binfmt-support qemu-user-static
sudo dpkg -i ubuntu-build-service/packages/*
sudo apt-get install -f
```

### 2.7、git配置

在~/linux-5.10-gen-rkr6目录下
```
git config --global user.name "your name"
git config --global user.email "your mail"
```


## 3、编译SDK

可参考 device/rockchip/common/README.md 编译说明。

### 3.1、SDK编译命令查看
```
make help
```

### 3.2、SDK配置：
可通过``` make lunch ```或者``` ./build.sh lunch ```进⾏配置，其他功能的配置可通过``` make menuconfig ```来配置相关属性


### 3.3、全自动编译

进⼊~/linux-5.10-gen-rkr6目录执⾏以下命令⾃动完成所有的编译：
```
./build.sh all # 只编译模块代码（u-Boot，kernel，Rootfs，Recovery）
# 需要再执⾏./mkfirmware.sh 进⾏固件打包
./build.sh # 编译模块代码（u-Boot，kernel，Rootfs，Recovery）
# 打包成update.img完整升级包
# 所有编译信息复制和⽣成到out⽬录下
```
默认是 Buildroot，可以通过设置坏境变量 RK_ROOTFS_SYSTEM 指定不同 rootfs。 

RK_ROOTFS_SYSTEM ⽬前可设定三种系统：buildroot、debian、 yocto 。

比如需要生成debian的命令如下：

```
export RK_ROOTFS_SYSTEM=debian
./build.sh
```

### 3.4、模块编译

```
./build.sh uboot
./build.sh kernel
./build.sh recovery
./build.sh rootfs
...
```


## 4、烧写固件

### 4.1、安装烧录工具

- Windows 驱动安装助手：```~/linux-5.10-gen-rkr6/tools/windows/DriverAssitant_v5.12.zip```

- Windows 烧写⼯具：```~/linux-5.10-gen-rkr6/tools/windows/RKDevTool_Release_v3.15```


### 4.2、打包工具

主要⽤于各分⽴固件打包成⼀个完整的update.img固件⽅便升级。

生成固件路径：```/tools/linux/Linux_Pack_Firmware/rockdev```

```
./mkupdate.sh
```

### 4.3、烧录固件

运行DriverAssitant_v5.12里面的DriverInstall.exe，先选择驱动卸载，然后再选择驱动安装。

打开RKDevTool.exe工具，给开发板上电并且用Type-C线与PC端连接，工具能识别到开发板的三种状态：

1. MASKROM

   开发板处于裸机状态，没有运行任何程序或者按住板载的maskrom按键上电

2. LOADER

   开发板在系统、uboot输入命令`reboot loader`或者按住板载的recovery按键（有些开发板没有引出）上电

3. ADB

   系统正在运行

#### 4.3.1、烧写完整系统固件

通过Type-C数据线连接开发板与pc，运行RKDevTool.exe。若驱动安装没有问题，工具会识别到两种情况：`发现一个MASKROM设备`和`发现一个ADB设备`

1. **自动识别到MASKROM设备**，如图：

   ![maskrom](https://docs.armsom.org/zh/assets/images/maskroot-flash-update-da496a92cae0342f11487c4f198f9de0.jpg)

   按【升级固件】按钮，点击【固件】选择要升级的固件文件（SDK编译的固件是update.img），固件包含完整的分区镜像


   加载固件之后，点击【升级】按钮，等待烧写完成即可

2. **自动识别到ADB设备**，

​	注：若显示发现一个ADB设备，则在升级固件界面点击【切换】即可进入loader烧录模式

- 按【固件】按钮，选择要升级的固件文件，加载固件之后，点击【升级】按钮，等待烧写完成即可。



#### 4.3.2、烧写分区固件

在开发中会有很多情况遇到只想要烧录uboot、kernel、system分区不想更新完整固件的情况，这个可以借助工具做到

这里以**更新kernel分区**来举例：
首先让开发板处于loader模式，可以在系统或者uboot输入命令`reboot loader`

   ![loader](https://docs.armsom.org/zh/assets/images/rkdevtool-install-emmc-197ac29887537cd991e15eb6044eaff0.png)

按照上面的步骤执行。
注意，一定要先点击【设备分区表】，读取设备分区镜像的地址会显示在右边，如上图所示读取内核的地址0x0000C800与配置的一致所以可以直接执行



## 5、ADB使用

这里主要介绍windows下使用adb进行调试

步骤：
- 下载windows版本的adb.zip，解压到C:\adb
- 配置环境变量：
  
  1、键盘按键：win + r
  
  2、打开“系统属性”窗口
  
  3、“高级”→“环境变量”→“系统变量”
  
  4、找到“Path”双击，新建，复制adb路径进去，点击“确定”按钮，添加成功
  
- 常用的adb命令
```
  adb help            //可查看所有命令
  adb version
  adb start-server     //启动adb服务
  adb kill-server      //关闭adb服务
  adb devices
  adb shell
  adb push [-p] <local> <remote>
  adb pull [-p] [-a] <remote> [<local>]
```
