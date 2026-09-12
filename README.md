# FR3 + HKV PyQt 控制台

单机械臂 FR3 与 HKV TG-9801 夹爪的 ROS 2 + MoveIt 2 控制界面，支持关节状态、夹爪开度、TCP 位姿、示教点采集、碰撞检测和抓取流程。

详细说明见 [`src/fr3_control_panel/README.md`](src/fr3_control_panel/README.md)。

## 快速运行（Ubuntu 22.04 / ROS 2 Humble）

```bash
git clone https://github.com/bobsuneay/fr3-hkv-control-panel.git
cd fr3-hkv-control-panel
sudo apt update
sudo apt install -y python3-pyqt5 python3-scipy python3-yaml \
  python3-colcon-common-extensions ros-humble-moveit \
  ros-humble-ros2-control ros-humble-ros2-controllers ros-humble-xacro
source /opt/ros/humble/setup.bash
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install
source install/setup.bash
```

### 一键启动虚拟仿真

```bash
bash install/fr3_control_panel/share/fr3_control_panel/scripts/start_panel.sh
```

它会启动虚拟 FR3、虚拟夹爪、MoveIt、RViz 和 PyQt 界面。打开界面后先点击“连接机械臂与夹爪”。

也可以使用：

```bash
ros2 launch fr3_control_panel mock_panel.launch.py
```

### 只查看界面

```bash
bash install/fr3_control_panel/share/fr3_control_panel/scripts/start_panel.sh --ui-only
```

Windows 用户可双击 `src/fr3_control_panel/scripts/start_panel.bat`，但 Windows 只能查看离线界面，不能运行 ROS 2、MoveIt 或真实硬件。

### 真实机械臂

先将厂商的 `fairino_msgs`、`fairino_hardware_v3_9_7` 和 `ros2_hkv_gripper` 编译并 source，然后准备已验收的 `real.yaml`：

```bash
source /opt/ros/humble/setup.bash
source ~/fr3_driver_ws/install/setup.bash
source ~/fr3-hkv-control-panel/install/setup.bash
bash ~/fr3-hkv-control-panel/install/fr3_control_panel/share/fr3_control_panel/scripts/start_panel.sh --real
```

真实模式默认读取 `~/fr3_config/real.yaml`。可通过 `FR3_REAL_CONFIG`、`FR3_CELL_CONFIG`、`HKV_SERIAL_PORT` 和 `HKV_BAUD_RATE` 覆盖配置路径和串口参数。

侧装机械臂需要同时设置示教器安装姿态和 `src/fr3_real_bringup/config/cell.yaml` 中的 `base.mounting: side`、基座位置及 `roll/pitch/yaw`。这些参数必须使用现场实测值；真实运行前还要加入侧装支架碰撞模型并完成急停、TCP 和负载检查。

