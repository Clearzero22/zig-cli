#!/usr/bin/env python3
"""
简单的自动化测试脚本用于测试Zig CLI库
Simple automated test script for testing the Zig CLI library
"""

import subprocess
import sys
import os

def run_command(command, cwd=None, timeout=30):
    """运行命令并返回结果"""
    try:
        result = subprocess.run(
            command,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Command timed out"
    except Exception as e:
        return -1, "", str(e)

def test_build():
    """测试项目构建"""
    print("1. Testing build...")
    returncode, stdout, stderr = run_command(["zig", "build"])
    
    if returncode == 0:
        print("   ✓ Build successful")
        return True
    else:
        print(f"   ✗ Build failed: {stderr}")
        return False

def test_unit_tests():
    """运行单元测试"""
    print("2. Testing unit tests...")
    returncode, stdout, stderr = run_command(["zig", "build", "test"])
    
    if returncode == 0:
        print("   ✓ Unit tests passed")
        return True
    else:
        print(f"   ✗ Unit tests failed: {stderr}")
        return False

def test_performance_tests():
    """运行性能测试"""
    print("3. Testing performance tests...")
    returncode, stdout, stderr = run_command(["zig", "build", "perf"])
    
    if returncode == 0:
        print("   ✓ Performance tests completed")
        return True
    else:
        print(f"   ✗ Performance tests failed: {stderr}")
        return False

def test_main_application():
    """测试主应用程序运行"""
    print("4. Testing main application...")
    returncode, stdout, stderr = run_command(["zig", "build", "run"], timeout=60)
    
    # 检查是否包含预期的输出内容
    expected_outputs = [
        "This is red text",
        "This is green text", 
        "This is blue text",
        "Progress Bar Demo",
        "Spinner Demo",
        "Table Demo"
    ]
    
    success = returncode == 0
    missing_outputs = []
    
    for expected in expected_outputs:
        if expected not in stdout:
            missing_outputs.append(expected)
            success = False
    
    if success:
        print("   ✓ Main application runs correctly")
        return True
    else:
        if missing_outputs:
            print(f"   ✗ Missing expected outputs: {', '.join(missing_outputs)}")
        else:
            print(f"   ✗ Application failed to run: {stderr}")
        return False

def test_help_command():
    """测试帮助命令"""
    print("5. Testing help command...")
    returncode, stdout, stderr = run_command(["zig", "build", "--help"])
    
    if returncode == 0 and "Usage" in stdout:
        print("   ✓ Help command works")
        return True
    else:
        print(f"   ✗ Help command failed: {stderr}")
        return False

def main():
    print("Starting automated tests for Zig CLI Library")
    print("=" * 50)
    
    # 检查zig是否已安装
    try:
        result = subprocess.run(["zig", "version"], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"Zig version: {result.stdout.strip()}")
        else:
            print("Error: Zig is not installed or not in PATH")
            sys.exit(1)
    except FileNotFoundError:
        print("Error: Zig is not installed or not in PATH")
        sys.exit(1)
    
    # 运行所有测试
    tests = [
        test_build,
        test_unit_tests,
        test_performance_tests,
        test_main_application,
        test_help_command
    ]
    
    results = []
    for test in tests:
        try:
            result = test()
            results.append(result)
            print()
        except Exception as e:
            print(f"   ✗ Test failed with exception: {e}")
            results.append(False)
            print()
    
    # 输出测试总结
    print("=" * 50)
    print("Test Summary:")
    print("=" * 50)
    
    passed = sum(results)
    total = len(results)
    failed = total - passed
    
    test_names = [
        "Build",
        "Unit Tests", 
        "Performance Tests",
        "Main Application",
        "Help Command"
    ]
    
    for i, (name, result) in enumerate(zip(test_names, results)):
        status = "PASS" if result else "FAIL"
        print(f"{status:4} | {name}")
    
    print("=" * 50)
    print(f"Total: {total} | Passed: {passed} | Failed: {failed}")
    
    if failed == 0:
        print("🎉 All tests passed!")
        return True
    else:
        print(f"❌ {failed} test(s) failed.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)