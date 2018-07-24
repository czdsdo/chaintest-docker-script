package main

import (
	"errors"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"time"

	mgo "gopkg.in/mgo.v2"
	"gopkg.in/mgo.v2/bson"
)

// BlockInfo 块信息
type BlockInfo struct {
	IP        string              `json:"ip"`
	BlockID   int                 `json:"blockid"`
	CreatTime bson.MongoTimestamp `json:"creattime"`
	Data      interface{}         `json:"data"`
}

// URL 数据库链接地址
const (
	URL                 string = "mongodb://root:!Q2w3e$R@180.101.204.40:27017"
	DBName              string = "chain"
	CollectionNameBlock string = "block"

	IPPath string = "/chain/AGENT_IP"
)

func main() {

	session, err := mgo.Dial(URL) //连接数据库
	if err != nil {
		panic(err)
	}
	defer session.Close()

	session.SetMode(mgo.Monotonic, true)

	db := session.DB(DBName)                     //数据库名称
	collectionBlock := db.C(CollectionNameBlock) //如果该集合已经存在的话，则直接返回

	//*******构造数据*******
	var blockinfo BlockInfo

	blockinfo.IP = readstring(IPPath)
	blockinfo.BlockID = 0

	for {
		blockinfo.CreatTime = bson.MongoTimestamp(time.Now().Unix())

		data, err := httpGet(blockinfo.BlockID)
		if err != nil {
			time.Sleep(1)
			// continue
			break
		}
		var f interface{}
		bson.UnmarshalJSON(data, &f)
		blockinfo.Data = f
		err = collectionBlock.Insert(&blockinfo)
		if err != nil {
			panic(err)
		}
		blockinfo.BlockID++
	}
}
func readstring(path string) string {
	fi, err := os.Open(path)
	if err != nil {
		panic(err)
	}
	defer fi.Close()
	fd, err := ioutil.ReadAll(fi)
	return string(fd)
}
func httpGet(blockid int) ([]byte, error) {
	resp, err := http.Get("http://127.0.0.1:8080/api/getInfo?blockId=" + strconv.Itoa(blockid))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, errors.New("not 200")
	}
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	if ttt := string(body[1:6]); ttt == "Error" {
		return nil, errors.New("Error")
	}
	return body, nil
}
