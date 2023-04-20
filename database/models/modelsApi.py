from fastapi import FastAPI, Request
from modelsService import sqlDataAccess
import datetime

app = FastAPI()
sql = sqlDataAccess()

# create middleware
@app.on_event("startup")
async def startup():
	# connect to database
    await sql.connect()

# create api end-point
@app.get("/findNews")
async def findNews(content: str):
	result = await sql.execute_storedProcedure('psGetNews', [content])
	return {"status": "success",
			"result": result}

@app.get("/reportData")
async def reportData():
    result = await sql.execute_storedProcedure('psGetLog', [None])
    return {"status": "success",
			"result": result}


@app.get("/insertData")
async def insertData(request: Request):
	# payload = await request.json()
	# print(payload)
	return {'status': 'success'}

@app.get("/getNews")
async def findNews(content: str):
	result = await sql.execute_storedProcedure('psGetNews', [None])
	return {"status": "success",
			"result": result}
