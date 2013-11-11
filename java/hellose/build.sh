rm -Rf target
mkdir -p target
javac -d target src/algoriddle/Hello.java
cd target
jar -cfe hello.jar algoriddle.Hello algoriddle/Hello.class
