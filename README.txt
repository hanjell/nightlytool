This tool offers the possibility of refresh/compile diferent products at diferent sandboxes automatically.

Requirements:
 1. Sandboxes are stored at /ae/ folder.
 2. Svn credentials must be stored at the system to be able to refresh svn repos unattended.

How to install:
 1. Just install the deb package

Where are the files:
 1. Executables are located at /usr/local/bin/
 1. Configuration is located at /usr/local/etc/nightlytool

How to configure:
 1. Copy sandbox_conf.json.sample to /usr/local/etc/nightlytool/sandbox_conf.json to set the configuration
 2. Add a daily task to execute it
 		00 20 * * Sun,Mon,Tue,Wed,Thu python /usr/local/bin/nightlytool.py

CONFIGURATION SECTIONS SAMPLE

A sandbox only to be refreshed (my-main-bcd) and a compiled sandbox (menu) where diferent products and targets are compiled

  "sandboxes": [
    {
      "name": "my-main-bcd",
      "refresh": true,
      "enabled": true,
      "products": []
    },
    {
      "name": "menu",
      "refresh": true,
      "enabled": true,
      "products": [
        {
          "name": "jaguar",
          "target": true,
          "host_cmake": true,
          "cortex": true
        },
        {
          "name": "walt",
          "target": true,
          "host_cmake": true,
          "cortex": true
        },
        {
          "name": "tatooine",
          "target": true,
          "host_cmake": true,
          "cortex": true
        },
        {
          "name": "vulcan",
          "target": true,
          "cortex": true
        }
      ]
    }
   ]

PRODUCTS SECTION SAMPLE

Here we define what compilation options we will choose:

"products": {
    "jaguar": {
      "target": "wrl80-haswell-dbg",
      "cortex": "cortex-threadx-ass"
    },
    "walt": {
      "target": "wrl60-haswell-dbg",
      "cortex": "cortex-threadx-ass"
    },
    "tatooine": {
      "target": "wrl60-haswell_x86_64-dbg",
      "cortex": "arm-threadx-ass"
    },
    "vulcan": {
      "target": "wrl60-haswell_x86_64-dbg",
      "cortex": "arm-threadx-ass"
    }
  }