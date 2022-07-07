---
title: Java8新特性
tags: java
abbrlink: 1038
date: 2021-12-15 14:40:55
---


该记录主要是java8的Lambda表达式以及Stream流的介绍与使用

<!--more-->

### 一、Lambda表达式

## 1.使用介绍

1. 举例： (o1,o2) -> Integer.compare(o1,o2);

2. 格式：

    -> :lambda操作符 或 箭头操作符

    -> 左边：lambda形参列表 （其实就是接口中的抽象方法的形参列表）

    -> 右边：lambda体 （其实就是重写的抽象方法的方法体）

3. Lambda表达式的本质：作为函数式接口的实例

4. 如果一个接口中，只声明了一个抽象方法，则此接口就称为函数式接口。我们可以在一个接口上使用 @FunctionalInterface 注解，

5.  所以以前用匿名实现类表示的现在都可以用Lambda表达式来写。

**总结：**

 *    ->左边：lambda形参列表的参数类型可以省略(类型推断)；如果lambda形参列表只有一个参数，其一对()也可以省略
 *    ->右边：lambda体应该使用一对{}包裹；如果lambda体只有一条执行语句（可能是return语句），省略这一对{}和return关键字

```java
@Test
public void test1(){
    //用lambda表达式开启线程
    new Thread(() -> System.out.println("线程开开启了")).start();
    //语法格式一：无参，无返回值
    Runnable runnable = new Runnable() {
        @Override
        public void run() {
            System.out.println("匿名内部类 runnable……");
        }
    };
    runnable.run();

    Runnable r1 = () -> System.out.println("lambda runnable……");
    r1.run();
    
    
    
    //需要一个参数但是没有返回值
        Consumer consumer = new Consumer() {
            @Override
            public void accept(Object o) {
                System.out.println("内部类实现 consumer……");
            }
        };
        consumer.accept("111");

        Consumer consumer1 = (x) -> System.out.println("lambda 实现consumer"+x);
        consumer1.accept("lambda ");
    
    
}
```

## 2.java内置的4大核心函数式接口

### （一）消费型接口 Consumer\<T>     void accept(T t)

> 有一个入参，无返回值

```java
//需要一个参数但是没有返回值
Consumer consumer = new Consumer() {
    @Override
    public void accept(Object o) {
        System.out.println("内部类实现 consumer……");
        }
};
consumer.accept("111");

Consumer consumer1 = (x) -> System.out.println("lambda 实现consumer"+x);
consumer1.accept("lambda ");
```



### （二) 供给型接口 Supplier\<T>     T get()

> 无入参 一个返回值

```
@Test
public void test2(){
    //供给型接口
    Supplier<String> supplier = ()-> {
        String s2 ="3";
        return s2.toUpperCase();
    };
    System.out.println("supplier.get() = " + supplier.get());
}
```

### （三) 函数型接口 Function<T,R>   R apply(T t)

> 一个入参，一个返回值

```java
@Test
public void test3(){
    //函数型接口
    Function<String,String> function = (x)->{
        System.out.println("x = " + x);
        return x.toUpperCase(Locale.ROOT);
    };
    System.out.println("function = " + function.apply("liuzheng"));
}
```



### （四) 断定型接口 Predicate\<T>    boolean test(T t)

> 一个入参，一个Boolean类型返回值

```java
@Test
public void test4() {
    //断言型接口
    Predicate<String> predicate = (x) -> x.contains("liuzheng");
    System.out.println("predicate = " + predicate.test("fdfdliuzh3eng"));
}
```

## 3.方法引用

**当要传递给Lambda体的操作，已经有实现的方法了，可以使用方法引用！**

### （一）方法引用的本质

方法引用本质上就是Lambda表达是，而Lambda表达式作为函数式接口的实例，所以方法引用也是函数式接口的实例

### （二）使用方式

类（对象）::  方法名

### （三）使用情况

1. **对象 ::  非静态方法**

> 它的形式参数全部传递给该方法作为参数

```java
@Test
public void test5(){
    //方法引用 1
    PrintStream out = System.out;
    Consumer<String> consumer = System.out::println;
    consumer.accept("方法引用");
}
```

2. **类 :: 静态方法**

> 它的形式参数全部传递给该方法作为参数

```java
Comparator<Integer> compare = Integer::compare;
System.out.println("compare = " + compare.compare(1, 4));
```

3. **类 :: 非静态方法**

> **第一个参数作为调用者**，后面的参数全部传递给该方法作为参数

```java
//BiPredicate中的boolean test(T t1, T t2);
//String中的boolean t1.equals(t2)
@Test
public void test6() {
    BiPredicate<String,String> pre1 = (s1,s2) -> s1.equals(s2);
    System.out.println(pre1.test("abc","abc"));

    System.out.println("*******************");
    BiPredicate<String,String> pre2 = String :: equals;
    System.out.println(pre2.test("abc","abd"));
}

// Function中的R apply(T t)
// Employee中的String getName();
@Test
public void test7() {
    Employee employee = new Employee(1001, "Jerry", 23, 6000);


    Function<Employee,String> func1 = e -> e.getName();
    System.out.println(func1.apply(employee));

    System.out.println("*******************");

    Function<Employee,String> func2 = Employee::getName;
    System.out.println(func2.apply(employee));


}
```

**要求** 针对方法1和方法2，要求接口中抽象方法的形参列表和返回值类型与方法引用的方法形参列表和返回值类型一致

## 4.构造器引用

和方法引用类似，函数式接口的抽象方法的形参列表和构造器的形参列表一致

抽象方法的返回值类型即为构造器所属的类的类型

```java
    //Supplier中的T get()
    //Employee的空参构造器：Employee()
    @Test
    public void test1(){

        Supplier<Employee> sup = new Supplier<Employee>() {
            @Override
            public Employee get() {
                return new Employee();
            }
        };
        System.out.println("*******************");

        Supplier<Employee>  sup1 = () -> new Employee();
        System.out.println(sup1.get());

        System.out.println("*******************");

        Supplier<Employee>  sup2 = Employee :: new;
        System.out.println(sup2.get());
    }


	//Function中的R apply(T t)
    @Test
    public void test2(){
        Function<Integer,Employee> func1 = id -> new Employee(id);
        Employee employee = func1.apply(1001);
        System.out.println(employee);

        System.out.println("*******************");

        Function<Integer,Employee> func2 = Employee :: new;
        Employee employee1 = func2.apply(1002);
        System.out.println(employee1);

    }

	//BiFunction中的R apply(T t,U u)
    @Test
    public void test3(){
        BiFunction<Integer,String,Employee> func1 = (id,name) -> new Employee(id,name);
        System.out.println(func1.apply(1001,"Tom"));

        System.out.println("*******************");

        BiFunction<Integer,String,Employee> func2 = Employee :: new;
        System.out.println(func2.apply(1002,"Tom"));

    }
```

大家可以把数组看做是一个特殊的类，则写法与构造器引用一致。

```java
	//数组引用
    //Function中的R apply(T t)
    @Test
    public void test4(){
        Function<Integer,String[]> func1 = length -> new String[length];
        String[] arr1 = func1.apply(5);
        System.out.println(Arrays.toString(arr1));

        System.out.println("*******************");

        Function<Integer,String[]> func2 = String[] :: new;
        String[] arr2 = func2.apply(10);
        System.out.println(Arrays.toString(arr2));

    }
```



# 二、Stream流

**常用操作**

```

 userList.stream().collect(Collectors.toMap(user::getUserId, t -> t, (oldvalue, newValue) -> newValue));
 参数说明：
 1. user::getUserId 作为map的key
 2. t->t value值为对象本身，也可以写 Function.identity()
 3. (oldvalue, newValue) -> newValue) 当key值冲突时，key对应的value值覆盖为newValue
```



## 1.概要介绍

* Stream关注的是对数据的运算，与CPU打交道
* Stream 自己不会存储元素
* Stream 不会改变源对象。相反，他们会返回一个持有结果的新Stream。
* Stream 操作是延迟执行的。这意味着他们会等到需要结果的时候才执行

**执行流程**

1. Stream的实例化
2. 一系列的中间操作（过滤、映射、...)  一个中间操作链，对数据源的数据进行处理
3. 终止操作

**一旦执行终止操作，就执行中间操作链，并产生结果。之后，不会再被使用**

## 2.执行流程详解

### （一）实例化

##### 1. 通过集合

```java
//创建 Stream方式一：通过集合
@Test
public void test1(){
    List<Employee> employees = EmployeeData.getEmployees();

    //        default Stream<E> stream() : 返回一个顺序流
    Stream<Employee> stream = employees.stream();

    //        default Stream<E> parallelStream() : 返回一个并行流
    Stream<Employee> parallelStream = employees.parallelStream();

}
```

##### 2. 通过数组

```java
//创建 Stream方式二：通过数组
@Test
public void test2(){
    int[] arr = new int[]{1,2,3,4,5,6};
    //调用Arrays类的static <T> Stream<T> stream(T[] array): 返回一个流
    IntStream stream = Arrays.stream(arr);

    Employee e1 = new Employee(1001,"Tom");
    Employee e2 = new Employee(1002,"Jerry");
    Employee[] arr1 = new Employee[]{e1,e2};
    Stream<Employee> stream1 = Arrays.stream(arr1);
}
```

##### 3.通过Stream的of

```java
//创建 Stream方式三：通过Stream的of()
@Test
public void test3(){
    Stream<Integer> stream = Stream.of(1, 2, 3, 4, 5, 6);
}
```

##### 4.创建无限流

```java
//创建 Stream方式四：创建无限流
@Test
public void test4(){

    //      迭代
    //      public static<T> Stream<T> iterate(final T seed, final UnaryOperator<T> f)
    //遍历前10个偶数
    Stream.iterate(0, t -> t + 2).limit(10).forEach(System.out::println);


    //      生成
    //      public static<T> Stream<T> generate(Supplier<T> s)
    Stream.generate(Math::random).limit(10).forEach(System.out::println);
}
```

### （二）中间链

##### 1.筛选与切片

###### （一）filter 

**filter(Predicate p)——接收 Lambda ， 从流中排除某些元素。**

```java
 List<Employee> employees = EmployeeData.getEmployees();
 employees.stream().filter(e->e.getSalary()>100).forEach(System.out::println);
```

###### （二）limit

**limit(n)——截断流，使其元素不超过给定数量。**

```java
employees.stream().limit(3).forEach(System.out::println);
```

###### （三）skip

**skip(n) —— 跳过元素，返回一个扔掉了前 n 个元素的流。若流中元素不足 n 个，则返回一个空流。与 limit(n) 互补**

```java
employees.stream().skip(3).forEach(System.out::println);
```

###### （四）distinct

 **distinct()——筛选，通过流所生成元素的 hashCode() 和 equals() 去除重复元素**

```java
list.add(new Employee(1010,"刘强东",40,8000));
list.add(new Employee(1010,"刘强东",41,8000));
list.add(new Employee(1010,"刘强东",40,8000));
list.add(new Employee(1010,"刘强东",40,8000));
list.add(new Employee(1010,"刘强东",40,8000));

//        System.out.println(list);

list.stream().distinct().forEach(System.out::println);
```

##### 2.映射

###### （五）map

 **map(Function f)——接收一个函数作为参数，将元素转换成其他形式或提取信息，该函数会被应用到每个元素上，并将其映射成一个新的元素。**

```java
List<String> list = Arrays.asList("aa", "bb", "cc", "dd");
list.stream().map(str -> str.toUpperCase()).forEach(System.out::println);
```

###### （六）flatMap

**flatMap(Function f)——接收一个函数作为参数，将流中的每个值都换成另一个流，然后把所有流连接成一个流。**

```java
//  flatMap(Function f)——接收一个函数作为参数，将流中的每个值都换成另一个流，然后把所有流连接成一个流。
Stream<Character> characterStream = list.stream().flatMap(StreamAPITest1::fromStringToStream);
characterStream.forEach(System.out::println);

//将字符串中的多个字符构成的集合转换为对应的Stream的实例
public static Stream<Character> fromStringToStream(String str){//aa
    ArrayList<Character> list = new ArrayList<>();
    for(Character c : str.toCharArray()){
        list.add(c);
    }
    return list.stream();

}
```

###### （七）peek

peek和map类似，peek方法接收一个Consumer的入参。了解λ表达式的应该明白 Consumer的实现类 应该只有一个方法，该方法返回类型为void。

正因为 `peek()` 不是一个最终操作，不会影响“哪些元素会流过”，所以十分适合在调试的时候，用来打印出流经管道的元素。例如：

```java
Stream.of("one", "two", "three", "four")
         .filter(e -> e.length() > 3)
         .peek(e -> System.out.println("Filtered value: " + e))
         .map(String::toUpperCase)
         .peek(e -> System.out.println("Mapped value: " + e))
         .collect(Collectors.toList());
```

##### 3.排序

###### （七）sorted()

###### 自然排序

```java
        List<Integer> list = Arrays.asList(12, 43, 65, 34, 87, 0, -98, 7);
        list.stream().sorted().forEach(System.out::println);
```

###### （八）sorted(Comparator com)

定制排序

```java
        List<Employee> employees = EmployeeData.getEmployees();
        employees.stream().sorted( (e1,e2) -> {

           int ageValue = Integer.compare(e1.getAge(),e2.getAge());
           if(ageValue != 0){
               return ageValue;
           }else{
               return -Double.compare(e1.getSalary(),e2.getSalary());
           }

        }).forEach(System.out::println);
    }
```

##### 4.匹配与查找

###### （九） allMatch(Predicate p)

> 检查是否匹配所有元素。

```java
//          练习：是否所有的员工的年龄都大于18
        boolean allMatch = employees.stream().allMatch(e -> e.getAge() > 18);
        System.out.println(allMatch);
```



###### （十） anyMatch(Predicate p)

> 检查是否至少匹配一个元素。

```java
//         练习：是否存在员工的工资大于 10000
        boolean anyMatch = employees.stream().anyMatch(e -> e.getSalary() > 10000);
        System.out.println(anyMatch);
```



###### （十一） noneMatch(Predicate p)

> 检查是否没有匹配的元素。

```java
//          练习：是否存在员工姓“雷”
        boolean noneMatch = employees.stream().noneMatch(e -> e.getName().startsWith("雷"));
        System.out.println(noneMatch);
```



###### （十二） findFirst

> 返回第一个元素

```java
//        findFirst——返回第一个元素
        Optional<Employee> employee = employees.stream().findFirst();
```



###### （十三） findAny

>  返回当前流中的任意元素

```java
        Optional<Employee> employee1 = employees.parallelStream().findAny();
        System.out.println(employee1);
```

##### 5. 收集

###### （十四）collect

将流转换为其他形式。接收一个 Collector接口的实现，用于给Stream中元素做汇总的方法

```java
        List<Employee> employees = EmployeeData.getEmployees();
        List<Employee> employeeList = employees.stream().filter(e -> e.getSalary() > 6000).collect(Collectors.toList());

        employeeList.forEach(System.out::println);
        System.out.println();
        Set<Employee> employeeSet = employees.stream().filter(e -> e.getSalary() > 6000).collect(Collectors.toSet());

        employeeSet.forEach(System.out::println);
```

##### 6.归约

###### （十五）reduce

可以将流中元素反复结合起来，得到一个值。返回 T

```java
//        练习1：计算1-10的自然数的和
        List<Integer> list = Arrays.asList(1,2,3,4,5,6,7,8,9,10);
        Integer sum = list.stream().reduce(0, Integer::sum);
        System.out.println(sum);


//        reduce(BinaryOperator) ——可以将流中元素反复结合起来，得到一个值。返回 Optional<T>
//        练习2：计算公司所有员工工资的总和
        List<Employee> employees = EmployeeData.getEmployees();
        Stream<Double> salaryStream = employees.stream().map(Employee::getSalary);
//        Optional<Double> sumMoney = salaryStream.reduce(Double::sum);
        Optional<Double> sumMoney = salaryStream.reduce((d1,d2) -> d1 + d2);
        System.out.println(sumMoney.get());
```

##### 7.其它

###### （十六）count

```java
        List<Employee> employees = EmployeeData.getEmployees();
        // count——返回流中元素的总个数
        long count = employees.stream().filter(e -> e.getSalary() > 5000).count();
        System.out.println(count);
```

###### （十七）max

```java
//        练习：返回最高的工资：
        Stream<Double> salaryStream = employees.stream().map(e -> e.getSalary());
        Optional<Double> maxSalary = salaryStream.max(Double::compare);
        System.out.println(maxSalary);
```

（十八）min

```java
//        练习：返回最低工资的员工
        Optional<Employee> employee = employees.stream().min((e1, e2) -> Double.compare(e1.getSalary(), e2.getSalary()));
        System.out.println(employee);
```

（十九）forEach

```java
//        forEach(Consumer c)——内部迭代
        employees.stream().forEach(System.out::println);
```



