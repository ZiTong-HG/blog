---
title: JavaScript中的Call、Apply、Bind的实现
categories: JavaScript
date: 2019-1-12 15:56:07
tags:
  - javascript
---

我们知道在 javascript 中 call 和 apply 以及 bind 都可以改变 this 指向，那么它们是怎么实现的呢？彼此之间有什么区别呢？首先我们先来分别解析一下它们,这篇文章简单的介绍了实现 call() , apply() , bind()的思路<!-- more -->

## JavaScript 中的 Call、Apply、Bind 的实现

### call 的解读与实现

```js
var leo = {
  name: "Leo",
  sayHai: function () {
    return "Hi I'm " + this.name
  },
  add: function (a, b) {
    console.log(this)
    return a + b
  },
}

var neil = {
  name: "Neil",
}

console.log(leo.sayHai.call(neil)) //Neil
console.log(leo.sayHai.call(null)) //undefine
```

如上面输出结果可以看出：
1.call 方法的第一个参数用于改变 this 指向，但是如果传入 null/undefined 值，this 会指向 window
2.call 方法需要把实参按照形参的个数传进去
现在我们已经知道如何使用 call 以及它的规则，那么我们来封装一个自己的 call 方法

```js
//ES3实现方法利用了eval()函数，将字符串当做JavaScript表达是执行
Function.prototype.es3call = function (ctx) {
  var ctx = ctx || global || window
  ctx.fn = this
  var args = []
  for (var i = 1; i < arguments.length; i++) {
    args.push("arguments[" + i + "]")
  }
  var result = eval("ctx.fn(" + args.join(",") + ")")
  delete ctx.fn
  return result
}

//ES6实现方法利用了扩展运算符rest运算符
Function.prototype.es6call = function (ctx) {
  var ctx = ctx || window || global
  ctx.fn = this
  var args = []
  for (var i = 1; i < arguments.length; i++) {
    args.push("arguments[" + i + "]")
  }
  const result = ctx.fn(...args)
  return result
}

console.log(leo.sayHai.es3call(neil)) //Neil
console.log(leo.sayHai.es3call(null)) //undefine
console.log(leo.sayHai.es6call(neil)) //Neil
console.log(leo.sayHai.es6call(null)) //undefine
```

### apply 的解读与实现

```js
console.log(leo.add.apply(neil, [2, 3])) //neil 5
console.log(leo.add.apply(null, [2, 3])) //window or global 5
```

1.apply 方法的第一个参数用于改变 this 指向，但是如果传入 null/undefined 值，this 会指向 window
2.apply 方法的第二个参数需要传入一个实参列表，也就是 arguments

```js
//ES3实现方法利用了eval()函数，将字符串当做JavaScript表达是执行
Function.prototype.es3apply = function (ctx, arr) {
  var ctx = ctx || global || window
  ctx.fn = this
  var result = null
  if (!arr) {
    result = ctx.fn()
  } else {
    if (!(arr instanceof Array)) throw new Error("params must Array")
    var args = []
    for (var i = 0; i < arr.length; i++) {
      args.push("arr[" + i + "]")
    }
    result = eval("ctx.fn(" + args.join(",") + ")")
  }
  delete ctx.fn
  return result
}

//ES6实现方法利用了扩展运算符rest运算符
Function.prototype.es6apply = function (ctx, arr) {
  var ctx = ctx || global || window
  ctx.fn = this
  var result = null
  if (!arr) {
    result = ctx.fn()
  } else {
    if (!(arr instanceof Array)) throw new Error("params must Array")
    var args = []
    for (var i = 0; i < arr.length; i++) {
      args.push("arr[" + i + "]")
    }
    result = ctx.fn(...args)
  }
  delete ctx.fn
  return result
}
```

```js
console.log(leo.add.es3apply(neil, [2, 3])) //neil 5
console.log(leo.add.es3apply(null, [2, 3])) //window or global 5
console.log(leo.add.es6apply(neil, [2, 3])) //neil 5
console.log(leo.add.es6apply(null, [2, 3])) //window or global 5
```

### bind 的解读与实现

```js
var value = "window"
var obj = {
  value: "obj",
}
Parent.prototype.value = "parent"
function Parent() {}
Child.prototype = new Parent()
function Child() {}
function show(name) {
  console.log(this.value, name)
}

show() //window undefined
var newShow1 = show.bind(obj)
newShow1() //obj undefined
var newShow2 = show.bind(null)
newShow2() //window undefined
var newShow3 = show.bind(obj, "test") //函数拥有预设的初始参数
newShow3() //obj test
new newShow3() //undefined test
var oS = Child.bind(obj)
var fn = new oS()
console.log(fn, fn.value) //Child{} "parent"  当使用new 操作符调用绑定函数时，参数obj无效。
```

根据上面的运行结果，我们可以总结一下 bind 的用法规则：
1.bind() 函数会创建一个新函数（称为绑定函数），新函数与被调函数（绑定函数的目标函数）具有相同的函数体
2.bind 方法的第一个参数也是用于改变 this 指向，如果传入 null/undefined，this 会指向 window 3.一个绑定函数也能使用 new 操作符创建对象：这种行为就像把原函数当成构造器。提供的 this 值被忽略
4.bind 方法可以使函数拥有预设的初始参数。这些参数（如果有的话）作为 bind()的第二个参数跟在 this（或其他对象）后面，之后它们会被插入到目标函数的参数列表的开始位置，传递给绑定函数的参数会跟在它们的后面。

```js
//ES3实现方法
Function.prototype.es3bind = function (ctx) {
  var ctx = ctx || global || window
  var self = this
  var args = Array.prototype.slice.call(arguments, 1)
  if (typeof this !== "function")
    throw new Error("what is trying to be bind is not callback")
  var temp = function () {}
  var fn = function () {
    var fnArgs = Array.prototype.slice.call(arguments, 0)
    return self.apply(this instanceof fn ? this : ctx, args.concat(fnArgs))
  }
  // 先让 temp 的原型方法指向 _this 即原函数的原型方法，继承 _this 的属性
  temp.prototype = this.prototype
  // 再将 fn 即要返回的新函数的原型方法指向 temp 的实例化对象
  // 这样，既能让 fn 继承 _this 的属性，在修改其原型链时，又不会影响到 _this 的原型链
  fn.prototype = new temp() //原型继承
  return fn
}

//ES6实现方法
Function.prototype.es6bind = function (ctx, ...rest) {
  if (typeof this !== "function")
    throw new Error("what is trying to be bind is not callback")
  var self = this
  return function F(...args) {
    if (this instanceof F) {
      return new self(...rest, ...args)
    }
    return self.apply(ctx, rest.concat(args))
  }
}
```

```js
show() //window undefined
var newShow1 = show.es3bind(obj)
newShow1() //obj undefined
var newShow2 = show.es3bind(null)
newShow2() //window undefined
var newShow3 = show.es3bind(obj, "test") //函数拥有预设的初始参数
newShow3() //obj test
new newShow3() //undefined test
var oS = Child.es3bind(obj)
var fn = new oS()
console.log(fn, fn.value) //Child{} "parent"  当使用new 操作符调用绑定函数时，参数obj无效。

show() //window undefined
var newShow1 = show.es6bind(obj)
newShow1() //obj undefined
var newShow2 = show.es6bind(null)
newShow2() //window undefined
var newShow3 = show.es6bind(obj, "test") //函数拥有预设的初始参数
newShow3() //obj test
new newShow3() //undefined test
var oS = Child.es6bind(obj)
var fn = new oS()
console.log(fn, fn.value) //Child{} "parent"  当使用new 操作符调用绑定函数时，参数obj无效。
```
