using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Text;
using BestHTTP.JSON;

//这个类是用于做json解析的
public class JsonTool  {

	public static string JsonStringFromObject(object obj)
	{
		return Json.Encode(obj);
	}
	
	public static byte[] JsonDataFromObject(object obj)
	{
		return Encoding.UTF8.GetBytes(JsonStringFromObject(obj));
	}

	public static object ObjectFromJsonString(string jsonStr)
	{
		return Json.Decode(jsonStr);
	}

	public static object ObjectFromJsonData(byte[] jsonData)
	{
		return ObjectFromJsonString(Encoding.Default.GetString(jsonData));
	}
}
