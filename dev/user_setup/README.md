## Create User

```java
sudo salt '*' state.apply user_setup.create_user saltenv=dev
sudo salt '*' state.apply user_setup.get_bash_files saltenv=dev
sudo salt '*' state.apply user_setup.setup_ssh_keys saltenv=dev
sudo salt '*' state.apply user_setup.setup_github saltenv=dev
```

