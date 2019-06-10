## 智能空调

### 功能

1. 远程控制空调

2. 监控当前空调环境的温湿度

### 独立开发部署

1. App （Android/iOS)

2. Server (Nodejs)

3. Device (Arduino)

### HomeAssistant


### 阿里云IoT


### 天猫精灵

---

### 设备端

#### 硬件设备

* esp8266

* 红外收发开发板  

#### 红外功能

使用库 IRremoteESP8266

https://github.com/markszabo/IRremoteESP8266

##### 红外接收

接收到红外code => 局域网广播 => 手机端和功能键绑定 发送到云端

##### 红外发送

手机端触发命令 => 云端获取命令转换成红外code => mqtt 下发到设备端 发送

#### 配网功能

使用库 WifiManager

https://github.com/tzapu/WiFiManager

##### 配网

首次上电通过指定AP接入

##### 重置功能

长按nodemcu上的rst按键，可以清除之前存储的wifi ssid 和 密码使其可以重新进行AP配网

##### 本地发现

未绑定前可以通过局域网UDP广播和本地手机通讯，使手机app上可以显示未绑定设备

#### 阿里云

##### 三元组烧写

`暂时`先考虑写死

##### MQTT连接

AsyncMqttClient

https://github.com/marvinroger/async-mqtt-client



MQTT Client ID  md5(PK+DN) 16位



#### 空调属性

### 客户端

* Android

* iOS

Flutter 进行跨平台开发

编写阿里云 API网关，长连接通道 相关插件

#### 首页

1. 绑定的设备列表页面

2. 每个设备的基本状态，开机，当前温度，模式信息

#### 添加设备

1. 显示当前局域网下没有被绑定过的设备

2. 点击进行绑定操作

#### 学习页面

#### 设备控制页面

#### 我的页面

1. 显示用户名 （微信名

2. 显示用户头像 （ 微信头像

3. 关于

#### 登入页面

1. 支持微信登入

### 服务端

* 腾讯云API网关

* 腾讯云 云函数

* 901 数据库
