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
	"fmt"

)

// BlockInfo 块信息
type BlockInfo struct {
	BlockID   int                 `json:"height"`
	IP        string              `json:"ip"`
	TXs      interface{}         `json:"txs"`
}

// URL 数据库链接地址
const (
	URL                 string = "mongodb://root:!Q2w3e$R@118.24.58.43:27017"
	DBName              string = "chain"
	CollectionNameBlock string = "wutongblock"
	IPPath string = "/wutong_IP"
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

	blockinfo.BlockID = 1
	blockinfo.IP = readstring(IPPath)

	for {
		//blockinfo.CreatTime = bson.MongoTimestamp(time.Now().Unix())

		data, err := httpGet(blockinfo.BlockID)
		if err != nil {
			time.Sleep(5)
			 continue
			//break
		}
		var f interface{}
		bson.UnmarshalJSON(data, &f)
		blockinfo.TXs = f
		err = collectionBlock.Insert(&blockinfo)
		if err != nil {
			panic(err)
		}
		fmt.Printf("%+v\n", blockinfo)
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
	resp, err := http.Get("http://119.27.168.192:9999/getblockbyheight?number=" + strconv.Itoa(blockid))                   
	// resp, err := http.Get("http://127.0.0.1:8080/api/getInfo?blockId=" + strconv.Itoa(blockid))
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
	if ttt := string(body[24:31]); ttt != "success" {
		return nil, errors.New("Error")
	}
	return body, nil
}
