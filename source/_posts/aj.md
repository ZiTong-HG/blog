---
title: JavaScript运行机制,Event Loop
date: 2018-12-26 11:22:58
categories: JavaScript
tags: 
 - javascript
---
JavaScript语言的一大特点就是单线程，也就是说，同一个时间只能做一件事。那么，为什么JavaScript不能有多个线程呢？这样能提高效率啊。<!--more-->

### 1.为什么JavaScript是单线程？###
JavaScript的单线程，与它的用途有关。作为浏览器脚本语言，JavaScript的主要用途是与用户互动，以及操作DOM。这决定了它只能是单线程，否则会带来很复杂的同步问题。比如，假定JavaScript同时有两个线程，一个线程在某个DOM节点上添加内容，另一个线程删除了这个节点，这时浏览器应该以哪个线程为准？

所以，为了避免复杂性，从一诞生，JavaScript就是单线程，这已经成了这门语言的核心特征，将来也不会改变。

为了利用多核CPU的计算能力，HTML5提出Web Worker标准，允许JavaScript脚本创建多个线程，但是子线程完全受主线程控制，且不得操作DOM。所以，这个新标准并没有改变JavaScript单线程的本质。

### 2.任务队列 ###
任务可以分为两种，一种为同步，另一种为异步（具有回调函数）。如下图：
![aj](/images/task.png)
所有的同步任务都在主线程上执行，形成一个执行栈 stack。当所有同步任务执行完毕后，它会去执行microtask queue中的异步任务（nextTick，Promise），将他们全部执行。主线程之外还有一个任务队列task queue，当有异步任务（DOM，AJAX，setTimeout，setImmediate）有结果的时候，就在任务队列里放一个事件，一旦执行栈和microtask queue任务执行完毕，系统就会读取任务队列，将取出排在最前面的事件加入执行栈执行，这种机制就是任务队列。

** Event Loop **

主线程在任务队列中读取事件，这个过程是循环不断地，所以这种运行机制叫做Event Loop（事件循环）

** nextTick、setImmediate、setTimeout **

nextTick是在执行栈同步代码结束之后，下一次Event Loop（任务队列）执行之前。当所有同步任务执行完，会在queue中执行nextTick，无论nextTick有多少层回调，都会执行完毕后再去任务队列，所以会造成一直停留在当前执行栈，无法执行任务队列

``` js
	process.nextTick(function () {
	    console.log('nextTick1');
	    process.nextTick(function (){console.log('nextTick2')});
	});
		  
	setTimeout(function timeout() {
	    console.log('setTimeout');
	}, 0)
```
执行完毕后输出nextTick1、nextTick2、setTimeout

setImmediate方法是在Event Loop（任务队列）末尾，也就是下一次Event Loop时执行。
setTimeout方法是按照执行时间，放入任务队列，有时快与setImmediate有时慢

``` js
	setImmediate(function () {
	    console.log('setImmediate1');
	    setImmediate(function (){console.log('setImmediate2')});
	});
	  
	setTimeout(function timeout() {
	    console.log('setTimeout');
	}, 0);
```
这段代码执行完可能是setImmediate1、setTimeout、setImmediate2，也可能是setTimeout、setImmediate1、setImmediate2，原因是setTimeout和setImmediate1都是在下次Event Loop中触发，所以先后不确定，但是setImmediate2肯定是最后，因为他是在setImmediate1任务队列之后，也就是下下次Event Loop执行

### 3.Node.js的Event Loop ###

Node.js也是单线程的Event Loop但是和浏览器有些区别，如图所示，

1.先通过Chrom V8引擎解析Javascript脚本

2.解析完毕后调用Node API

3.LIBUV库负责Node API的执行，将不同任务分配给不同的线程，形成一个Event Loop（任务队列）

4.最后Chrom V8引擎将结果返回给用户

![aj](/images/node.png)

** Node.js Event Loop原理 **

Node.js的特点是事件驱动，非阻塞单线程。当应用程序需要I/O操作的时候，线程并不会阻塞，而是把I/O操作交给底层库（LIBUV）。此时node线程会去处理其他任务，当底层库处理完I/O操作后，会将主动权交还给Node线程，所以Event Loop的用处是调度线程，例如：当底层库处理I/O操作后调度Node线程处理后续工作，所以虽然node是单线程，但是底层库处理操作依然是多线程