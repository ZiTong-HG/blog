---
title: JavaScript模块化
date: 2019-02-23 16:45:26
categories: JavaScript
tags:
 - javascript    
---

### ** 为什么要使用模块化? ** ###

当我们一个项目越做越大的时候，维护起来肯定没那么方便，且多人协作的去进行开发，当中肯定会遇到很多的问题，例如：

1. 方法的覆盖： 很有可能你定义的一些函数会覆盖公共类中同名的函数，因为你可能根本就不知道公共类中有哪些函数，也不知道是如何命名的。<!--more-->
2. 这些公共的组件： 但是你又不知道这些组件又会依赖哪些模块，同时在维护这些公共方法的时候，会新增一些依赖或者删除一些依赖，那么每个引入这些公共方法的地方都需要去对应的新增或者删除。等等，还会存在很多的问题。

我们使用模块化就是为了让各个模块之间相对独立，可能每个文件就是一个功能块，能满足于某项特定的功能，这样我们在引用某项功能的时候就会很方便。

### ** CommonJS ** ###

Node 应用由模块组成，采用 CommonJS 模块规范。

每个文件就是一个模块，有自己的作用域。在一个文件里面定义的变量、函数、类，都是私有的，对其他文件不可见,CommonJS规范加载模块是同步的，也就是说，加载完成才可以执行后面的操作，Node.js主要用于服务器编程，模块一般都是存在本地硬盘中，加载比较快，所以Node.js采用CommonJS规范。且CommonJS模块输出的是值的缓存, 运行时加载。
CommonJS规范规定，每个模块内部，module变量代表当前模块。这个变量是一个对象，它的exports属性（即module.exports）是对外的接口。加载某个模块，其实是加载该模块的module.exports属性。

```ts
// tools.ts 
const add = (a: number, b: number) =>{
  return a + b
}

const reduce = (a: number, b: number) => {
  return a - b
}

const multy = (a: number, b: number) => {
	return a * b
}

exports.add = add
exports.reduce = reduce

export default multy

// 等价于
module.exports = {
  add,
  reduce
}
```

```ts
// app.ts
const tools = require('./tools.ts')
tools.add(2, 3)       // 5
tools.reduce(3, 2)    // 1
```

Node内部提供一个Module构建函数。所有模块都是Module的实例。
```js
// Module 构造函数
function Module(id, parent) {
  this.id = id          //模块的识别符，通常是带有绝对路径的模块文件名
  this.exports = {}     //表示模块对外输出的值
  this.parent = parent  //返回一个对象，表示调用该模块的模块
  ...
}
```

```ts
// tools.ts 
const add = (a: number, b: number) =>{
  return a + b
}

exports.add = add
console.log(module)

// 输出
Module {
  id: '.',
  exports: { add: [Function: add] },
  parent: null,
  filename: 'C:\\Users\\viruser.v-desktop\\Desktop\\zz\\aa.js', //模块的文件名，带有绝对路径
  loaded: false,      //返回一个布尔值，表示模块是否已经完成加载
  children: [],       //返回一个数组，表示该模块要用到的其他模块
  paths: [ 
    'C:\\Users\\viruser.v-desktop\\Desktop\\zz\\node_modules',
    'C:\\Users\\viruser.v-desktop\\Desktop\\node_modules',
    'C:\\Users\\viruser.v-desktop\\node_modules',
    'C:\\Users\\node_modules',
    'C:\\node_modules' 
  ] 
}
```

如果在命令行下调用某个模块，比如node tools.js，那么module.parent就是null。如果是在脚本之中调用，比如require('./tools.js')，那么module.parent就是调用它的模块。利用这一点，可以判断当前模块是否为入口脚本。
```js
if (!module.parent) {
  // ran with `node something.js`
  app.listen(8088, function() {
    console.log('app listening on port 8088')
  })
} else {
  // used with `require('/.something.js')`
  module.exports = app
}
```
为了方便，Node为每个模块提供一个exports变量，指向module.exports。这等同在每个模块头部，有一行这样的命令。造成的结果是，在对外输出模块接口时，可以向exports对象添加方法。注意，不能直接将exports变量指向一个值，因为这样等于切断了exports与module.exports的联系。
```js
const exports = module.exports
```

### ** AMD ** ###

大多数的同学都应该了解RequireJS，而且RequireJS是基于AMD规范的。AMD是"Asynchronous Module Definition"的缩写，意思就是"异步模块定义"。它采用异步方式加载模块，模块的加载不影响它后面语句的运行。所有依赖这个模块的语句，都定义在一个回调函数中，等到加载完成之后，这个回调函数才会运行。且同样是运行时加载的，用require.config()指定引用路径等，用define()定义模块，用require()加载模块, 但是不同于CommonJS，它要求两个参数：

定义模块

```js
// define([module], callback)
define(['myLib'], () =>{
	function foo(){
		console.log('mylib')
	}
	return {
		foo : foo
　}
})
```

```js
require.config({
  baseUrl: "js/lib",
  paths: {
    "jquery": "jquery.min",  				//实际路径为js/lib/jquery.min.js
    "underscore": "underscore.min",
  }
});
```

使用模块
```js
// require([module], callback)
require(['myLib'], mod => {
  mod.foo()
})

// myLib
```

#### ** 为什么要使用AMD规范呢? ** ####

因为AMD是专门为浏览器中js环境设计的规范。它吸取了CommonJS的一些优点，但是没有全部都照搬过来。也是非常容易上手。

### ** CMD ** ###

CMD在很多地方和AMD有相似之处，在这里我只说两者的不同点。首先，CMD规范和CommonJS规范是兼容的，相比AMD，它简单很多。遵循CMD规范的模块，可以在Node.js中运行。SeaJS是推荐是用CMD的写法，那么就使用SeaJS来编写一个简单的例子：

```js
// AMD写法  AMD的依赖需要前置书写
define(["a", "b", "c", "d", "e", "f"], function(a, b, c, d, e, f) { 
  // 等于在最前面声明并初始化了要用到的所有模块
  a.doSomething()
  if (false) {
    // 即便没用到某个模块 b，但 b 还是提前执行了
    b.doSomething()
  }
})

// CMD写法 CMD的依赖就近书写即可，不需要提前声明
define(function(require, exports, module) {
  var a = require('./a')  //在需要时申明  同步
  a.doSomething()
  if (false) {
    var b = require('./b')
    b.doSomething()
	}
	require.async('a', math =>{  //异步
    a.add(1, 2);
  })
})

/** sea.js **/
// 定义模块 math.js
define(function(require, exports, module) {
  var $ = require('jquery.js')
  var add = function(a,b){
    return a+b
  }
  exports.add = add
})
// 加载模块
seajs.use(['math.js'], function(math){
  var sum = math.add(1+2)
})
```

CMD规范我们可以发现其API职责专一，例如同步加载和异步加载的API都分为require和require.async，而AMD的API比较多功能。

### ** UMD ** ###

UMD是AMD和CommonJS的糅合

AMD模块以浏览器第一的原则发展，异步加载模块。
CommonJS模块以服务器第一原则发展，选择同步加载，它的模块无需包装(unwrapped modules)。
这迫使人们又想出另一个更通用的模式UMD （Universal Module Definition）。希望解决跨平台的解决方案。

UMD先判断是否支持Node.js的模块（exports）是否存在，存在则使用Node.js模块模式。
在判断是否支持AMD（define是否存在），存在则使用AMD方式加载模块。

```js
(function (window, factory) {
  if (typeof exports === 'object') {
    module.exports = factory()
  } else if (typeof define === 'function' && define.amd) {
    define(factory)
  } else {
    window.eventUtil = factory()
  }
})(this, function () {
  //module ...
})
```

### ** ESModule ** ###

历史上，JavaScript一直没有模块（module）体系，无法将一个大程序拆分成互相依赖的小文件，再用简单的方法拼装起来。其他语言都有这项功能，比如Ruby的 require 、Python的 import ，甚至就连CSS都有 @import ，但是JavaScript任何这方面的支持都没有，这对开发大型的、复杂的项目形成了巨大障碍。

ES6模块的设计思想，是尽量的静态化，使得编译时就能确定模块的依赖关系，以及输入和输出的变量。CommonJS和AMD模块，都只能在运行时确定这些东西。比如，CommonJS模块就是对象，输入时必须查找对象属性。

模块功能主要由两个命令构成： export 和 import。export 命令用于规定模块的对外接口,import 命令用于输入其他模块提供的功能

```js
// a.js
var num1 = 1
var num2 = 2

export { num1, num2 }
```

```js
// b.js
import { num1, num2 } from './a.js'

function add(num1, num2) {
  return num1 + num2
}

console.log(add(num1, num2))
```
如果想为输入的变量重新取一个名字，import命令要使用 as 关键字，将输入的变量重命名。
```js
import { num1 as snum } from './a'
```

mport 命令具有提升效果，会提升到整个模块的头部

```js
add();
import { add} from './tools'
```

如果在一个模块之中，先输入后输出同一个模块， import 语句可以与 export 语句写在一起。

```js
export { es6 as default } from './a'

// 等同于
import { es6 } from './a'
export default es6
```

还可以使用整体加载，即用星号（ * ）指定一个对象，所有输出值都加载在这个对象上面, 但不包括default

```js
import * as tools from './a'
import multy from './a
tools.add(2, 1)  		//3
tools.reduce(2, 1)  //1
multy(2,1)					//2
```

#### ** ES6模块加载的实质 ** ####

ES6模块加载的机制，与CommonJS模块完全不同。CommonJS模块输出的是一个值的拷贝，而ES6模块输出的是值的引用。

CommonJS模块输出的是被输出值的拷贝，也就是说，一旦输出一个值，模块内部的变化就影响不到这个值

```js
// lib.js
var counter = 3
function incCounter() {
  counter++;
}
module.exports = {
  counter: counter,
  incCounter: incCounter,
}
```

```js
// main.js
var mod = require('./lib')
console.log(mod.counter) // 3
mod.incCounter()
console.log(mod.counter) // 3
```

lib.js 模块加载以后，它的内部变化就影响不到输出的 mod.counter 了。这是因为 mod.counter 是一个原始类型的值，会被缓存。除非写成一个函数，才能得到内部变动后的值
```js
// lib.js
var counter = 3
function incCounter() {
  counter++
}
module.exports = {
  get counter() {
    return counter
  },
  incCounter: incCounter,
}
```

```js
// main.js
var mod = require('./lib')
console.log(mod.counter) // 3
mod.incCounter()
console.log(mod.counter) // 4
```

ES6模块的运行机制与CommonJS不一样，它遇到模块加载命令 import 时，不会去执行模块，而是只生成一个动态的只读引用。等到真的需要用到时，再到模块里面去取值，换句话说，ES6的输入有点像Unix系统的”符号连接“，原始值变了，import 输入的值也会跟着变。因此，ES6模块是动态引用，并且不会缓存值，模块里面的变量绑定其所在的模块。
