rm -Rf target
mkdir -p target/WEB-INF/classes
javac -cp ../lib/javaee-api-7.0.jar -d target/WEB-INF/classes src/algoriddle/HelloServlet.java
cd target
jar -cf hello.war WEB-INF
