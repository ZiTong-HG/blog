---
title: JavaScript 原型与原型链以及继承方式
date: 2019-02-16 14:54:43
categories: JavaScript
tags:
 - javascript    
---
### ** 原型 ** ###
ECMAScript 中描述了原型链的概念，并将原型链作为实现继承的主要方法。其基本思想是利用原
型让一个引用类型继承另一个引用类型的属性和方法。简单回顾一下构造函数、原型和实例的关系：每
个构造函数都有一个原型对象，原型对象都包含一个指向构造函数的指针，而实例都包含一个指向原型
对象的内部指针。<!--more-->那么，假如我们让原型对象等于另一个类型的实例，结果会怎么样呢？显然，此时的
原型对象将包含一个指向另一个原型的指针，相应地，另一个原型中也包含着一个指向另一个构造函数
的指针。假如另一个原型又是另一个类型的实例，那么上述关系依然成立，如此层层递进，就构成了实
例与原型的链条。这就是所谓原型链的基本概念

### ** 继承 ** ###
继承是OO 语言中的一个最为人津津乐道的概念。许多OO 语言都支持两种继承方式：接口继承和
实现继承。接口继承只继承方法签名，而实现继承则继承实际的方法。如前所述，由于函数没有签名，
在ECMAScript 中无法实现接口继承。ECMAScript 只支持实现继承，而且其实现继承主要是依靠原型链
来实现的

### ** 原型与原型链 ** ###

1. prototype ：每个函数都会有这个属性，这里强调，是函数，普通对象是没有这个属性的（这里为什么说普通对象呢，因为JS里面，一切皆为对象，所以这里的普通对象不包括函数对象）。它是构造函数的原型对象；
2. __proto__ ：每个对象都有这个属性,，这里强调，是对象，同样，因为函数也是对象，所以函数也有这个属性。它指向构造函数的原型对象；
3. constructor ：这是原型对象上的一个指向构造函数的属性。

```tsx
function Pig(name: string, age: number){
  this.name = name
  this.age = age
}

// 创建Pig实例
const Pepig = new Pig('Pepig', 18)

// 在实例化的时候，prototype上的属性会作为原型对象赋值给实例, 也就是Pepig原型
Pepig.__proto__ === Pig.prototype    // true

// Pig是一个函数对象, 它是Function对象的一个实例 Funtcion的原型对象又指向Object对象
Pig.__proto__ === Function.prototype  // true

Function.prototype.__proto__ === Object.prototype // true

Object.prototype.__proto__ === null // true

// 原型对象上的constructor指向构造函数本身
Pig.prototype.constructor = Pig

```
### ** 继承的方式 ** ###
 
#### ** 1.原型链继承 ** ####
```tsx
function P(name: string){
  this.name = name
}

P.prototype.sayName = function(){
  console.log('P', this.name)
}

function C(name: string){
  this.name = name
}

C.prototype = new P('P')
C.prototype.constructor = C

C.prototype.sayName = function(){
  console.log('C', this.name)
}

const child = new C('C')
child.sayName() // 'C' C

```
##### ** 缺点 ** #####
1. 子类型无法给超类型传递参数，在面向对象的继承中，我们总希望通过 var child = new Child('son', 'father'); 让子类去调用父类的构造器来完成继承。而不是通过像这样 new Parent('father') 去调用父类。
2. 引用类型值的原型属性会被所有实例共享

#### ** 2.借用构造函数(经典继承) ** ####
```tsx
function P(age: number){
  this.names = ['alex', 'jet']
  this.age = age
}

function C(age: number){
  P.call(this, age)
}

const child = new C()
child.names.push('mark')  
child.names         // alex jet mark

const child1 = new C()
child1.names        // alex jet

const child = new C('15')
child.age           // 15

const child = new C('18')
child.age           // 18

```
##### ** 优点 ** #####
1. 避免了引用类型的属性被所有实例共享
2. 可以在 Child 中向 Parent 传参

##### ** 缺点 ** #####
1. 方法都在构造函数中定义，因此函数复用就无从谈起了。而且，在超类型的原型中定义的方法，对子类型而言也是不可见的。

#### ** 3.组合继承 ** ####

```tsx
function P(name: string){
  this.name = name
  this.colors = ['yellow', 'blue']
}

P.prototype.getName = function(){
  console.log(this.name)
}

function C(name: string, age: number){
  P.call(this, name)
  this.age = age
}

C.prototype = new P()

const child = new C('jet', 18)
child.colors.push('black')  // yellow blue black
child.name                  // jet
child.age                   //  18

const child1 new C('jack', 20)
child1.colors               // yellow blue
child1.name                 // jack
child1.age                  // 20    
```

##### ** 优点 ** #####
1. 融合原型链继承和构造函数的优点，是 JavaScript 中最常用的继承模式。
2. 都会调用两次超类型构造函数

#### ** 4.原型式继承 ** ####

```tsx
function object(o: Object){ 
  function F(){}
  F.prototype = o
  return new F() 
}

var person = { 
  name: "Nicholas", 
  friends: ["Shelby", "Court", "Van"] 
}
 
var anotherPerson = object(person)
anotherPerson.name = "Greg"
anotherPerson.friends.push("Rob")
 
var yetAnotherPerson = object(person)
yetAnotherPerson.name = "Linda"
yetAnotherPerson.friends.push("Barbie")
 
alert(person.friends)   //"Shelby,Court,Van,Rob,Barbie" 
```

##### ** 特点 ** #####
1. 包含引用类型值的属性始终都会共享相应的值，就像使用原型模式一样

#### ** 5.寄生式继承 ** ####

思想： 寄生式继承的思路与寄生构造函数和工厂模式类似，即创建一个仅用于封装继承过程的函数，该
函数在内部以某种方式来增强对象，最后再像真地是它做了所有工作一样返回对象
```tsx
function createAnother(original){ 
  var clone = object(original)   //通过调用函数创建一个新对象 
  clone.sayHi = function(){      //以某种方式来增强这个对象 
    alert("hi") 
  } 
  return clone                   //返回这个对象 
}
```

##### ** 缺点 ** #####
1. 使用寄生式继承来为对象添加函数，会由于不能做到函数复用而降低效率

#### ** 6.寄生组合式继承 ** ####

```tsx
function inheritPrototype(subType, superType){ 
  var prototype = object(superType.prototype);     //创建对象 
  prototype.constructor = subType;                 //增强对象 
  subType.prototype = prototype;                   //指定对象 
}
```

##### ** 优点 ** #####
1.只调用了一次 SuperType 构造函数，并且因此避免了在 SubType. 
prototype 上面创建不必要的、多余的属性。与此同时，原型链还能保持不变；因此，还能够正常使用
instanceof 和 isPrototypeOf()