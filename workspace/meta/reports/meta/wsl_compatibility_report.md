# WSL 兼容性检测报告

**检测时间**：2026-04-30
**目标**：判断 Windows 上的 Claude Code 能否通过 WSL 调用 Linux 工具链（特别是几何/拓扑工具：Regina、Sage、SnapPy 等）

---

## 1. WSL 基础信息

| 项目 | 值 |
|---|---|
| Distro | Ubuntu 24.04.3 LTS (Noble Numbat) |
| Kernel | 6.6.87.2-microsoft-standard-WSL2 |
| 架构 | x86_64 |
| 状态 | `Stopped`（按需启动），WSL 2 |
| 第二个 distro | `docker-desktop`（也 Stopped） |

**注意**：`/etc/wsl.conf` 里有一个未识别的 key `wsl2.networkingMode`（输出里有警告），不影响功能但建议检查。

---

## 2. Python 环境

| 项目 | 值 |
|---|---|
| Python | 3.12.3（GCC 13.3.0，2026-01-22 构建） |
| python3 路径 | `/usr/bin/python3` |
| pip3 | **未安装**（`pip3: command not found`） |
| numpy / sympy / mpmath | **全部未安装** |
| regina / snappy / curver / flipper / sage | **全部未安装** |
| sudo / apt | 已安装 |

**结论**：WSL 里只有裸 Python，连 pip 都没有。任何科学计算都需要先装 `python3-pip` 或 `python3-venv`。

---

## 3. 文件互通

| 方向 | 测试 | 结果 |
|---|---|---|
| WSL → Windows 读 | `cat /mnt/c/Users/12729/Desktop/Math/lean-toolchain` | ✅ 输出 `leanprover/lean4:v4.30.0-rc2` |
| WSL → Windows 写 | `echo ... > /mnt/c/Users/.../wsl_test.txt` | ✅ 写入并能从 Windows 侧读取 |
| WSL Python 跑 Windows 路径脚本 | `wsl python3 /mnt/c/Users/.../wsl_smoke.py` | ✅ 正常执行，CWD=`/mnt/c/...` |

**结论**：双向互通完全正常。WSL 里挂载点 `/mnt/c/...` 直接对应 `C:\...`，Claude Code 可以在 Windows 文件系统里写脚本，让 WSL Python 读取执行。

⚠️ **性能提示**：跨 9P 协议访问 `/mnt/c` 比 WSL 原生 `~` 慢一个数量级。大量 IO 密集任务建议把工作目录放到 WSL 原生（`/home/$USER/...`），用脚本 `cp` 同步结果到 `/mnt/c/...`。

---

## 4. 已装的几何/拓扑包

**全部未安装**：

```
dpkg -l | grep -iE 'regina|sagemath|snappy'  → NONE
```

WSL 里**完全是空白状态**，没有任何拓扑/几何工具。

---

## 5. apt 仓库可用性（关键名称冲突⚠️）

### 5.1 数值 / 符号计算（直接可装）

✅ Ubuntu 24.04 默认仓库里有：
- `python3-numpy`
- `python3-sympy`
- `python3-mpmath`
- 还有 `python3-bottleneck`, `python3-numexpr` 等加速包

→ 一条 `sudo apt install python3-{numpy,sympy,mpmath}` 即可。

### 5.2 几何/拓扑包（**需要警惕**）

❌ Ubuntu 24.04 默认仓库**没有**真正的拓扑工具：

| 你想要的 | apt 里能搜到的 | 是否同一个东西？ |
|---|---|---|
| Regina（3-流形拓扑） | `regina-rexx`（REXX 语言解释器） | ❌ **完全不是同一个东西**，纯名字撞车 |
| SnapPy（双曲 3-流形） | `python3-snappy`（Google 压缩库） | ❌ **完全不是同一个东西**，纯名字撞车 |
| SageMath（完整 CAS） | `sagemath-database-*`（只是若干数据库） | ❌ Ubuntu 从 20.04 起就移除了主 sagemath 包 |
| Curver / Flipper | 无 | — |

**结论**：通过默认 apt **拿不到任何真正的几何/拓扑工具**。要装它们必须走以下任一路径：

1. **Regina topology**：官方推荐 PPA 或源码构建（`https://regina-normal.github.io/install.html#linux`）
2. **SnapPy**：`pip install snappy-manifolds snappy`（需要 X 库做 GUI，纯 CLI 用法可不要 GUI 部分）
3. **SageMath**：（a）conda-forge 装（推荐，最省事）；（b）官方编译好的 binary tarball；（c）build from source（4-8 小时编译）；apt 装不了
4. **Curver / Flipper**：`pip install curver flipper-lib`

---

## 6. 调用延迟

```
time wsl bash -c "python3 -c 'print(\"latency test\")'"
real  0m0.381s
```

**约 380ms cold-start** 每次 `wsl bash -c "..."` 调用。

含义：
- 长时运行脚本（>10s）：开销可忽略
- 高频小调用（数百次循环）：必须把循环放在**一次** WSL 进程里跑，不要每次重启 WSL bash
- 实际场景下推荐：写一个完整的 Python 脚本到 `/mnt/c/.../foo.py`，用一次 `wsl python3 /mnt/c/.../foo.py` 跑完

---

## 7. 结论与推荐方案

### 整体判断
WSL 通信链路**完全可用**：Claude Code（Windows）↔ Ubuntu 24.04（WSL2）双向读写、Python 调用、apt 都能正常工作。但 WSL 端**完全空白**——连 pip、numpy 都没有，更别提几何工具。

### 推荐方案：**B（增强版）= WSL 作为几何计算专用环境**

```
┌─────────────────────┐         ┌──────────────────────────────┐
│  Claude Code        │ orchestrate │  WSL Ubuntu 24.04        │
│  (Windows, Math/)   │ ─────────▶│  Python 3.12 + 几何栈     │
│  - 写题目/proof.md  │ ◀───────── │  - regina, snappy        │
│  - 调度 Agent       │  result  │  - curver, flipper         │
│  - 阅读结果         │          │  - sympy, numpy, mpmath    │
└─────────────────────┘          └──────────────────────────────┘
       (在 /mnt/c/Users/12729/Desktop/Math 里读写, 双侧共享文件)
```

**调用模式**：
```bash
wsl python3 /mnt/c/Users/12729/Desktop/Math/<script>.py
```
或更稳健（避免 9P 慢 IO）：
```bash
wsl bash -c "cd ~/work && python3 script.py && cp result.json /mnt/c/.../"
```

### 安装清单（待你确认后再执行）

**第 1 步：基础**（5 分钟，~150 MB）
```bash
sudo apt install -y python3-pip python3-venv python3-numpy python3-sympy python3-mpmath
```

**第 2 步：拓扑**（按需选择）

| 工具 | 推荐安装方式 | 大小 / 时间 |
|---|---|---|
| SnapPy | `pip install --user snappy snappy-manifolds` | ~50MB / 2分钟 |
| Curver | `pip install --user curver` | ~5MB / 30秒 |
| Flipper | `pip install --user flipper` | ~5MB / 30秒 |
| Regina (topology) | PPA: `sudo add-apt-repository ppa:bcaw/regina && sudo apt install regina-normal python3-regina` | ~100MB / 5分钟 |
| SageMath | **conda-forge** 路线（建议）：`conda install -c conda-forge sage` | ~3GB / 20分钟 |

**第 3 步**（可选）：在 WSL 里建一个 venv 把所有几何包关进去，避免污染系统 Python：
```bash
python3 -m venv ~/geo-env
source ~/geo-env/bin/activate
pip install snappy curver flipper sympy mpmath numpy
```
然后 Claude Code 调用：`wsl bash -c "source ~/geo-env/bin/activate && python3 /mnt/c/.../script.py"`

### 备选方案对比

| 方案 | 优点 | 缺点 |
|---|---|---|
| **A** Windows 直接装 Python + 几何包 | 无 WSL 开销 | Windows 上 SnapPy/Regina 安装难度高，常缺依赖；Sage 在 Windows 仅 WSL 版 |
| **B** WSL 全栈（推荐） | 包齐、装得快、社区主流 | 380ms cold start、跨文件系统 IO 慢 |
| **C** Docker container | 可复现、隔离干净 | 需先装 Docker、镜像 1-3GB、调用层多一层 |

### 当前状态总结
- ✅ WSL 通信链路可用，无需修复
- ⚠️ `/etc/wsl.conf` 有未知 key `wsl2.networkingMode`，建议清理（不阻塞）
- ❌ WSL 端是裸环境，需要装 pip + 数值栈 + 拓扑栈
- 💡 **下一步**：等你拍板方案 B，我可以分阶段安装；任何一步装坏了都可以单独重做

---

**未做的事**（按你要求只检测不安装）：
- 没有运行 `sudo apt update` / `apt install`
- 没有装 pip
- 没有装任何 Python 包
- 没有改 `/etc/wsl.conf`
- 没有动 PPA
