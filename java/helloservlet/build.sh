rm -Rf target
mkdir -p target/WEB-INF/classes
javac -verbose -cp ../lib/javaee-api-7.0.jar -d target/WEB-INF/classes src/algoriddle/HelloServlet.java
cd target
jar -cvf hello.war WEB-INF
