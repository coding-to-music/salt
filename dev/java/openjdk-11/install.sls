java_install:
  pkg.installed:
    - name: openjdk-11-jdk

java_home:
  cmd.run:
    - name: |
        echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))" | sudo tee -a /etc/profile
        source /etc/profile
    - unless: test -n "$JAVA_HOME"
