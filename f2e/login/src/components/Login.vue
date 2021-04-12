<template>
  <div>
    <h1>Welcome</h1>
    <div class="outer_label">
      <img src="../assets/login_icon.png">
    </div>
    <el-form class="login_form" ref="loginForm" method="POST">
      <el-input class="user" name="username" maxlength=11 prefix-icon="el-icon-user" placeholder="手机号" v-model="username"/>
      <el-input class="password"  maxlength=16 show-password prefix-icon="el-icon-lock" placeholder="密码" v-model="inputPassword"/>
      <el-input type="hidden" name="password" ref="password" v-model="password"/>
      <el-button class="login_btn"  type="primary" round @click="login">登录</el-button>
    </el-form>
  </div>
</template>

<script>
import { setTimeout } from 'timers';

// const axios = require('axios')
const md5 = require('md5')


export default {
  name: 'Login',
  props: {
    msg: String
  },
  data() {
    return {
      username: '',
      inputPassword: '',
      password: 'aaa'
    }
  },

  methods: {
    async login() {
      if (!this.username) {
          this.$message.error('请输入用户名');
          return;
      }
      if (!this.inputPassword) {
          this.$message.error('请输入密码');
          return;
      }

      this.password = md5(this.inputPassword)
      this.$refs.password.$el
      console.log(this.password)
      setTimeout(() => {
        this.$refs.loginForm.$el.submit()
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

  .login_form {
    padding-top: 10%;
    padding-left: 10%;
    padding-right: 10%;
  }
  .login_logo {
    height: 100%;
  }

  .password {
    margin-top: 32px;
  }

  .login_btn {
    width: 100%;
  }

</style>
