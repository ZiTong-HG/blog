---
title: Exports、Module.exports、Export、Export defalut
date: 2018-11-30 11:15:04
categories: JavaScript
tags:
 - amd
 - cmd
 - javascript
---

首先exports和module.exports是出自于CommonJs规范里面的,熟悉NodeJs的朋友或许知道，废话不多    说！根据这个规范，每个文件就是一个模块，有自己的作用域。在一个文件里面定义的变量、函数、类，都是私有的，对 其 他文件不可见。<!-- more -->CommonJS规范规定，每个模块内部，module变量代表当前模块。这个变量是一个对象，它的 exports属 性（即 module.exports）是对外的接口。加载某个模块，其实是加载该模块的module.exports属 性,module.exports导出对应require导入，export导出对应import导入。

### 1.exports、module.exports ###
``` js
    var x = 5;
    var addX = (value) => value + x
    module.exports.x = x;
    module.exports.addX = addX;
```
上面代码通过module.exports输出变量x和函数addX。

require方法用于加载模块。
``` js
    var example = require('./example.js');
    console.log(example.x);         // 5
    console.log(example.addX(1));   // 6
```
看了刚刚这段commonjs规范上面的介绍可以知道以下区别与联系：
其实exports变量是指向module.exports，加载模块实际是加载该模块的module.exports。这等同在每个模块头 
部，有一行这样的命令。
``` js
    var exports = module.exports;
```
于是我们可以直接在 exports 对象上添加方法，表示对外输出的接口，如同在module.exports上添加一样。注 
意，不能直接将exports变量指向一个值，因为这样等于切断了exports与module.exports的联系。

### 2.export、export default ###
export和export default是属于ES6语法
模块功能主要由：export和import构成。export导出模块的对外接口，import命令导入其他模块暴露的接口。
export其实和export default就是写法上面有点差别，一个是导出一个个单独接口，一个是默认导出一个整体接 
口。使用import命令的时候，用户需要知道所要加载的变量名或函数名，否则无法加载。这里就有一个简单写法不用 
去知道有哪些具体的暴露接口名，就用export default命令，为模块指定默认输出。
``` js
    demo.js

    export a = "1";
    export b = (a)=> a + b;
    export c = {
        d: '3',
        e: '4'
    }
```
export导出的变量或对象或方法，则对应的需要用import来导入
``` js
    import { a, b, c } from './demo.js'
    //或者等价
    import *as newName from './demo.js' 
```
针对export变量导出,es6 的规范 import * as obj from "xxx" 会将 "xxx" 中所有 export 导出的内容组合成一个对象返回

 export defalut
``` js
     demo1.js

    export defalut{
        a: '2',
        add(b,c) {
            return b + c
        }
    }
```
import 导入
``` js
    import whatever from './demo1.js'
```
但一个文件中只能使用一次export defalut