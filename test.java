import java.util.Scanner;
public class test
{
	public static void main(String[] args)
	{
		System.out.println(generate("word_case words pipes read_from_case write_to_case standard_error_redirect_case ampersand_case"));
	}
	
	public static String generate(String s){
		String remove = s.substring(10);
		String result = new String();
		if(remove.contains("read_from_case"))
			result += "setReadFlag(1);\n";
		else
			result += "setReadFlag(0);\n";
		
		if(remove.contains("write_to_case"))
			result += "setWriteFlag(1);\n";
		else
			result += "setWriteFlag(0);\n";
		
		if(remove.contains("standard_error_redirect_case") && !(remove.contains("standard_error_redirect_case2")))
			result += "setErrorFlag(1);\n";
		else if(remove.contains("standard_error_redirect_case2"))
			result += "setErrorFlag(2);\n";
		else
			result += "setErrorFlag(0);\n";
		
		if(remove.contains("pipe_case") || remove.contains("pipes"))
			result += "setPipeFlag(1);\n";
		else
			result += "setPipeFlag(0);\n";
		
		if(remove.contains("ampersand_case"))
			result += "setAmpersandFlag(1);\n";
		else
			result += "setAmpersandFlag(0);\n";
		
		if(remove.contains("append_case"))
			result += "setAppendFlag(1);\n";
		else
			result += "setAppendFlag(0);\n";
		
		result += "execute();\n";
		return result;
	}
}
