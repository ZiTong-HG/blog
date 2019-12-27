---
title: JavaScript深浅拷贝
date: 2018-12-28 18:48:08
categories: JavaScript
tags: 
 - javascript
---

浅拷贝和深拷贝都是对于JS中的引用类型而言的，浅拷贝就只是复制对象的引用，如果拷贝后的对象发生变化，原对象也会发生变化。只有深拷贝才是真正地对对象的拷贝<!-- more -->

### 1.深拷贝与浅拷贝的区别 ###

   如何区分深拷贝与浅拷贝，简单点来说，就是假设B复制了A，当修改A时，看B是否会发生变化，如果B也跟着变了，说明这是浅拷贝，拿人手短，如果B没变，那就是深拷贝，自食其力。

### 2.栈堆、基本数据类型、引用数据类型 ###
   栈堆：存放数据的地方
   基本数据类型：number,string,boolean,null,undefined.
   引用数据类型(Object类)有常规名值对的无序对象{a:1}，数组[1,2,3]，以及函数等。

### 3.浅拷贝 ###

``` js
      let a= [0,1,2,3,4],b=a;
      console.log(a===b);
      a[0] = 1
      console.log(a,b)
```
![af](/images/6206483-259060db5d78ed21.webp)

### 4.深拷贝 ###

``` js
    function deepClone(obj){
        let objClone = Array.isArray(obj)?[]:{};
        if(obj && typeof obj==="object"){
            for(key in obj){
                if(obj.hasOwnProperty(key)){
                    //判断ojb子元素是否为对象，如果是，递归复制
                    if(obj[key]&&typeof obj[key] ==="object"){
                        objClone[key] = deepClone(obj[key]);
                    }else{
                        //如果不是，简单复制
                        objClone[key] = obj[key];
                    }
                }
            }
        }
        return objClone;
    } 
     
    let a=[1,2,3,4],b=deepClone(a);
    a[0]=2;
    console.log(a,b);
```
![af](/images/6206483-c20cfb902b33e72c.webp)


### 5.引用类型和基本类型栈内存储 ###

#### 5.1基本类型 ####

![af](/images/6206483-c746503248c3529f.webp)


#### 5.2引用类型 ####

    
![af](/images/6206483-3743f3a8c2da4e57.webp)


### 6.JS中拷贝Array的slice和concat方法 ###

  #### 6.1.slice拷贝 ####

``` js
    var a = [1,2,3];
    var b = a.slice(); //slice
    console.log(b === a);
    a[0] = 4;
    console.log(a);
    console.log(b);
```
![af](/images/6206483-8f34a68fe6d58d00.webp)

  #### 6.2.concat拷贝 ####
``` js
    var a = [1,2,3];
    var b = a.concat();  //concat
    console.log(b === a);
    a[0] = 4;
    console.log(a);
    console.log(b);
```
![af](/images/c.webp)

看到结果，如果你觉得，这两个方法是深拷贝，那就恭喜你跳进了坑里！
来看看有意思的例子吧

``` js
    var a = [[1,2,3],4,5];
    var b = a.slice();
    console.log(a === b);
    a[0][0] = 6;
    console.log(a);
    console.log(b);
```
![af](/images/6206483-9b258e06b03bfe48.webp)


可以看到slice和contact对于第一层是深拷贝，但对于多层的时候，是复制的引用，所以是浅拷贝
### 7.JSON 对象的 parse 和 stringify都是深拷贝 ###

``` js
    var obj = {name:'cancan',age:23,company : { name : '阿里', address : '杭州'} };
    var obj_json = JSON.parse(JSON.stringify(obj));
    console.log(obj === obj_json);
    obj.company.name = "cancan82";
    obj.name = "haha";
    console.log(obj);
    console.log(obj_json);
```
![af](/images/6206483-fee5d7337ba45d5b.webp)