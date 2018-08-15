## Bare Bone Configuration Management 

For the ease of development purposes, do not use it in production.



### Initiate Vault

##### Native Method

Execute `./deploy.R` to start a vault. Default location `~/.bbcfg`. Not tested on Windows (probably not working). 

```bash
./deploy.R <your secret>

Rscript --vanilla plumber.R &
```

If vault has been initiated successfully, a dummy config id has been created for testing purpose. 

```bash
curl -X GET 'http://dev.configs:7788/config?token=1234&id=DummyOne' 
```

The command above should return 

```json
{
    "user": "admin",
    "password": "HelloWorld2018",
    "host": "somewhere",
    "port": "someport"
}
```

##### Docker Container

```bash
# first build the image
docker build -t <image-name> .

# then start container
# map continer ~/.bbcfg to host for persistent storage
docker run -it -v $HOME/.bbcfg:$HOME/.bbcfg -dp 7788:7788 dev.configs:dev
```

### Vault Operation

Use the following swaggers to trigger various vault operations,

---

`/get` - **GET** request

**Parameter:**

* token - secret to initiate vault
* id - which config to retrieve

**Return Value:**

Configuration of `id` in `json` format

**Example:**

```bash
curl -X GET 'http://127.0.0.1:7788/config?token=1234&id=Dummy.One' 
```

---

`/update` - **POST** request 

**Parameter:**

* token - secret to initiate vault
* id - which config to update
* key - key of config
* value - value of key

**Return Value:**

Success or empty {} for failure

**Example:**

```bash
curl -X POST \
  http://127.0.0.1:7788/update \
  -d 'token=1234&id=Dummy.One&key=color&value=red'
```

---

`/delete` - **GET** request

**Parameter:**

* token - secret to initiate vault
* id - which config to modify
* key - which key to drop

**Return Value:**

Success or empty {} for failure

**Example:**

```bash
curl -X GET 'http://127.0.0.1:7788/delete?token=1234&id=Dummy.One&key=color' 
```

---

`/insert` - **POST** request

Parameter:

* token - secret to initiate vault
* id - config name to register
* {*key-value pairs*}

Return Value:

Success or empty {} for failure

Example:

```bash
curl -X POST \
  http://dev.configs:7788/insert \
  -d 'token=1234&id=Dummy.Two&user=tom&password=hellokitty&color=pink&weather=27&size=big'
```

