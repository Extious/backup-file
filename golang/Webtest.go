package main

import (
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

type User struct {
	gorm.Model        // 包含ID、CreatedAt、UpdatedAt、DeletedAt字段
	Name       string `gorm:"default:'xiaowangzi'"`
	Email      string
}

func main() {
	// 参考 https://github.com/go-sql-driver/mysql#dsn-data-source-name 获取详情
	dsn := "root:1234@tcp(127.0.0.1:3306)/test?charset=utf8mb4&parseTime=True&loc=Local"
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		panic(err.Error())
	}

	// 创建表自动迁移
	db.AutoMigrate(&User{})
	// 插入数据
	//user := User{Name: "张三", Email: "zhangsan@example.com"}
	//db.Create(&user)

	//创建数据实例
	users := &User{Name: "ddd", Email: "SSS@qq.com"}
	db.Create(&users)

	//db.Find(&users)

	//更新数据
	//db.Model(&users).Update("Name", "赵四")

}

/* package main

import (
	"encoding/json"

	"github.com/gin-gonic/gin"
	"github.com/thinkerou/favicon"
)

func main() {
	//创建一个服务
	ginServer := gin.Default()
	ginServer.Use(favicon.New("./go.ico"))
	//加载一个静态页面
	ginServer.LoadHTMLGlob("templates/*")
	//加载资源网站
	ginServer.Static("/static", "./static")
	//访问地址，处理我们的请求
	ginServer.GET("/hello", func(context *gin.Context) {
		context.JSON(200, gin.H{"msg": "hello,world"})
	})
	//响应一个页面给前端
	ginServer.GET("/index", func(context *gin.Context) {
		context.HTML(200, "index.html", gin.H{
			"msg": "这是后台传的数据",
		})
	})
	//传参1
	ginServer.GET("/user/info", func(context *gin.Context) {
		userid := context.Query("userid")
		username := context.Query("username")
		context.JSON(200, gin.H{
			"userid":   userid,
			"username": username,
		})
		//传参2
		ginServer.GET("/user/info/:userid/:username", func(ctx *gin.Context) {
			userid := ctx.Param("userid")
			username := ctx.Param("username")
			ctx.JSON(200, gin.H{
				"userid":   userid,
				"username": username,
			})
		})
		//前端给后端传json
		ginServer.POST("/json", func(ctx *gin.Context) {
			b, _ := ctx.GetRawData()
			var m map[string]interface{}
			_ = json.Unmarshal(b, &m)
		})

	})
	//服务器端口
	ginServer.Run(":8081")
}
*/
