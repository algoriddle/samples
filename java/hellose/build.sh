mkdir -p target
javac -d target src/algoriddle/Hello.java
cd target
jar -cvfe hello.jar algoriddle.Hello algoriddle/Hello.class
