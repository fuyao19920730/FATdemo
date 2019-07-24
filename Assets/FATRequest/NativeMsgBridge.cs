using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

public class NativeMsgBridge : MonoBehaviour {

	private static NativeMsgBridge instance;
	private Action<string> deviceInfoCallback;
	
	public static NativeMsgBridge getInstance()
	{
		if (instance == null)
		{
			GameObject receiverGo = GameObject.Find("NativeMsgReceiver");
			if (receiverGo == null)
			{
				receiverGo = new GameObject("NativeMsgReceiver");
				DontDestroyOnLoad(receiverGo);

				receiverGo.AddComponent<NativeMsgBridge>();
			}
			instance = receiverGo.GetComponent<NativeMsgBridge>();
		}

		return instance;
	}

	//调用原生的方法
	[DllImport("__Internal")]
	private static extern void GetDeviceAllInfo();
	
	
	//原生调用unity的方法
	public void DeviceInfoCallback(string deviceInfo)
	{
		//返回设备的json
		if (deviceInfoCallback != null)
		{
			deviceInfoCallback(deviceInfo);
		}
	}
	
	//Unity 中调用的获取设备信息的方法
	public void GetDeviceInfo(Action<string> deviceInfoCallback)
	{

		this.deviceInfoCallback = deviceInfoCallback;
//#if  UNITY_IOS && !UNITY_EDITOR
		GetDeviceAllInfo();

//#elif UNITY_ANDROID && !UNITY_EDITOR

//#else
//        
//#endif
	} 
	
}
