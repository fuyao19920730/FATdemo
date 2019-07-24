using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeviceInfo  {

	/*
	 *     /// <summary>
    /// 必须
    /// </summary>
    public string appname;
    public string packagename;
    public string appvercode;
    /// <summary>
    /// 应用版本号，必须
    /// </summary>
    public string appver;
    /// <summary>
    /// 应用版本号，必须,上报的为设备id，
    /// </summary>
    
	 */

	public static string appname;
	public static string packagename;
	public static string appvercode;
	public static string appver;
	public static string userid;
	public static string idfv;
	public static string gps_adid;
	public static string devicecountry;
	public static string netstatus;
	public static string carriername;
	public static string syslanguage;
	public static string sysver;
	public static string devicemodel;
	public static string timezone;
	public static string unitysdkver;
	public static string sdkver;

	public static void GetDeviceInfo()
	{
		//调用原生获取信息
		NativeMsgBridge.getInstance().GetDeviceInfo(DeviceInfoCallback);
	}

	private static void DeviceInfoCallback(string obj)
	{
		throw new System.NotImplementedException();
		//在这里解析json,赋值给静态变量
		
		
	}
}
