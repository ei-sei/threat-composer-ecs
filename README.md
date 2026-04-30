# threat-composer-ecs

### Objective
Build, containerise and deploy the threat composer application using **Docker**, **Terraform**, and **ECS**, with **HTTPS** and a **custom domain**

## 01 - Local App Setup
> yarn and served installed `npm install -g yarn serve`

```
cd app
yarn install
yarn build
yarn global add serve
serve -s build

#yarn start
http://localhost:3000/workspaces/default/dashboard
```

