#!/usr/bin/env python3
"""
自动化测试脚本用于测试Zig CLI库
Automated test script for testing the Zig CLI library
"""

import subprocess
import sys
import os
import time
import re
from typing import List, Tuple, Optional

class ZigCLITestRunner:
    def __init__(self, project_path: str):
        self.project_path = project_path
        self.test_results = []
        
    def run_command(self, command: List[str], timeout: int = 30) -> Tuple[int, str, str]:
        """运行命令并返回结果"""
        try:
            result = subprocess.run(
                command,
                cwd=self.project_path,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            return result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            return -1, "", "Command timed out"
        except Exception as e:
            return -1, "", str(e)
    
    def test_build(self) -> bool:
        """测试项目构建"""
        print(" Testing build...")
        returncode, stdout, stderr = self.run_command(["zig", "build"])
        
        if returncode == 0:
            print("  ✓ Build successful")
            self.test_results.append(("Build", True, "Project builds successfully"))
            return True
        else:
            print(f"  ✗ Build failed: {stderr}")
            self.test_results.append(("Build", False, f"Build failed: {stderr}"))
            return False
    
    def test_unit_tests(self) -> bool:
        """运行单元测试"""
        print(" Testing unit tests...")
        returncode, stdout, stderr = self.run_command(["zig", "build", "test"])
        
        if returncode == 0:
            print("  ✓ Unit tests passed")
            self.test_results.append(("Unit Tests", True, "All unit tests passed"))
            return True
        else:
            print(f"  ✗ Unit tests failed: {stderr}")
            self.test_results.append(("Unit Tests", False, f"Unit tests failed: {stderr}"))
            return False
    
    def test_performance_tests(self) -> bool:
        """运行性能测试"""
        print(" Testing performance tests...")
        returncode, stdout, stderr = self.run_command(["zig", "build", "perf"])
        
        if returncode == 0:
            print("  ✓ Performance tests completed")
            self.test_results.append(("Performance Tests", True, "Performance tests completed successfully"))
            return True
        else:
            print(f"  ✗ Performance tests failed: {stderr}")
            self.test_results.append(("Performance Tests", False, f"Performance tests failed: {stderr}"))
            return False
    
    def test_main_application(self) -> bool:
        """测试主应用程序运行"""
        print(" Testing main application...")
        returncode, stdout, stderr = self.run_command(["zig", "build", "run"], timeout=60)
        
        # 检查是否包含预期的输出内容
        expected_outputs = [
            "This is red text",
            "This is green text",
            "This is blue text",
            "Progress Bar Demo",
            "Spinner Demo",
            "Table Demo",
            "Alice",
            "Laptop"
        ]
        
        success = returncode == 0
        missing_outputs = []
        
        for expected in expected_outputs:
            if expected not in stdout:
                missing_outputs.append(expected)
                success = False
        
        if success:
            print("  ✓ Main application runs correctly")
            self.test_results.append(("Main Application", True, "Application runs and outputs expected content"))
        else:
            if missing_outputs:
                error_msg = f"Missing expected outputs: {', '.join(missing_outputs)}"
            else:
                error_msg = f"Application failed to run: {stderr}"
            print(f"  ✗ Main application issues: {error_msg}")
            self.test_results.append(("Main Application", False, error_msg))
        
        return success
    
    def test_color_functionality(self) -> bool:
        """测试颜色功能"""
        print(" Testing color functionality...")
        
        # 创建一个简单的测试文件
        test_file_content = '''
const std = @import("std");
const cli_color = @import("src/lib/cli_color.zig");

pub fn main() !void {
    try cli_color.printlnColor("Test red text", .red);
    try cli_color.printlnColor("Test green text", .green);
    try cli_color.printlnColor("Test blue text", .blue);
}
'''
        
        test_file_path = os.path.join(self.project_path, "test_color.zig")
        try:
            with open(test_file_path, 'w') as f:
                f.write(test_file_content)
            
            # 编译测试文件
            returncode, stdout, stderr = self.run_command([
                "zig", "build-exe", "test_color.zig", 
                "--name", "test_color"
            ])
            
            if returncode == 0:
                # 运行测试程序
                exe_path = os.path.join(self.project_path, "test_color")
                returncode, stdout, stderr = self.run_command([exe_path])
                
                if returncode == 0 and "Test red text" in stdout:
                    print("  ✓ Color functionality works")
                    self.test_results.append(("Color Functionality", True, "Color functions work correctly"))
                    success = True
                else:
                    print(f"  ✗ Color functionality failed: {stderr}")
                    self.test_results.append(("Color Functionality", False, f"Color test failed: {stderr}"))
                    success = False
            else:
                print(f"  ✗ Failed to compile color test: {stderr}")
                self.test_results.append(("Color Functionality", False, f"Failed to compile: {stderr}"))
                success = False
                
        except Exception as e:
            print(f"  ✗ Error testing color functionality: {e}")
            self.test_results.append(("Color Functionality", False, f"Error: {e}"))
            success = False
        finally:
            # 清理测试文件
            try:
                if os.path.exists(test_file_path):
                    os.remove(test_file_path)
                if os.path.exists(os.path.join(self.project_path, "test_color")):
                    os.remove(os.path.join(self.project_path, "test_color"))
            except:
                pass
                
        return success
    
    def test_progress_bar_functionality(self) -> bool:
        """测试进度条功能"""
        print(" Testing progress bar functionality...")
        
        # 创建一个简单的进度条测试文件
        test_file_content = '''
const std = @import("std");
const progress = @import("src/lib/progress.zig");

pub fn main() !void {
    var pb = try progress.ProgressBar.init(10, null);
    defer pb.finish() catch {};
    
    var i: usize = 0;
    while (i <= 10) : (i += 1) {
        try pb.update(i);
    }
    try pb.finish();
}
'''
        
        test_file_path = os.path.join(self.project_path, "test_progress.zig")
        try:
            with open(test_file_path, 'w') as f:
                f.write(test_file_content)
            
            # 编译测试文件
            returncode, stdout, stderr = self.run_command([
                "zig", "build-exe", "test_progress.zig", 
                "--name", "test_progress"
            ])
            
            if returncode == 0:
                print("  ✓ Progress bar functionality compiles")
                self.test_results.append(("Progress Bar Functionality", True, "Progress bar compiles successfully"))
                success = True
            else:
                print(f"  ✗ Progress bar functionality failed to compile: {stderr}")
                self.test_results.append(("Progress Bar Functionality", False, f"Failed to compile: {stderr}"))
                success = False
                
        except Exception as e:
            print(f"  ✗ Error testing progress bar functionality: {e}")
            self.test_results.append(("Progress Bar Functionality", False, f"Error: {e}"))
            success = False
        finally:
            # 清理测试文件
            try:
                if os.path.exists(test_file_path):
                    os.remove(test_file_path)
                if os.path.exists(os.path.join(self.project_path, "test_progress")):
                    os.remove(os.path.join(self.project_path, "test_progress"))
            except:
                pass
                
        return success
    
    def test_spinner_functionality(self) -> bool:
        """测试旋转状态条功能"""
        print(" Testing spinner functionality...")
        
        # 创建一个简单的旋转状态条测试文件
        test_file_content = '''
const std = @import("std");
const spinner = @import("src/lib/spinner.zig");

pub fn main() !void {
    var s = try spinner.Spinner.init("Testing...", null);
    defer _ = s.stop("Test complete!") catch {};
    
    try s.start();
    try s.update();
    try s.update();
    try s.stop("Test complete!");
}
'''
        
        test_file_path = os.path.join(self.project_path, "test_spinner.zig")
        try:
            with open(test_file_path, 'w') as f:
                f.write(test_file_content)
            
            # 编译测试文件
            returncode, stdout, stderr = self.run_command([
                "zig", "build-exe", "test_spinner.zig", 
                "--name", "test_spinner"
            ])
            
            if returncode == 0:
                print("  ✓ Spinner functionality compiles")
                self.test_results.append(("Spinner Functionality", True, "Spinner compiles successfully"))
                success = True
            else:
                print(f"  ✗ Spinner functionality failed to compile: {stderr}")
                self.test_results.append(("Spinner Functionality", False, f"Failed to compile: {stderr}"))
                success = False
                
        except Exception as e:
            print(f"  ✗ Error testing spinner functionality: {e}")
            self.test_results.append(("Spinner Functionality", False, f"Error: {e}"))
            success = False
        finally:
            # 清理测试文件
            try:
                if os.path.exists(test_file_path):
                    os.remove(test_file_path)
                if os.path.exists(os.path.join(self.project_path, "test_spinner")):
                    os.remove(os.path.join(self.project_path, "test_spinner"))
            except:
                pass
                
        return success
    
    def test_table_functionality(self) -> bool:
        """测试表格功能"""
        print(" Testing table functionality...")
        
        # 创建一个简单的表格测试文件
        test_file_content = '''
const std = @import("std");
const table = @import("src/lib/table.zig");

pub fn main() !void {
    const columns = [_]table.ColumnConfig{
        table.ColumnConfig{ .header = "Name", .alignment = .left },
        table.ColumnConfig{ .header = "Age", .alignment = .right },
    };
    
    var t = try table.Table.init(std.heap.page_allocator, &columns, null);
    defer t.deinit();
    
    try t.addRow(&[_][]const u8{ "Alice", "25" });
    try t.addRow(&[_][]const u8{ "Bob", "30" });
    
    // We won't actually render the table in this test to avoid output
}
'''
        
        test_file_path = os.path.join(self.project_path, "test_table.zig")
        try:
            with open(test_file_path, 'w') as f:
                f.write(test_file_content)
            
            # 编译测试文件
            returncode, stdout, stderr = self.run_command([
                "zig", "build-exe", "test_table.zig", 
                "--name", "test_table"
            ])
            
            if returncode == 0:
                print("  ✓ Table functionality compiles")
                self.test_results.append(("Table Functionality", True, "Table compiles successfully"))
                success = True
            else:
                print(f"  ✗ Table functionality failed to compile: {stderr}")
                self.test_results.append(("Table Functionality", False, f"Failed to compile: {stderr}"))
                success = False
                
        except Exception as e:
            print(f"  ✗ Error testing table functionality: {e}")
            self.test_results.append(("Table Functionality", False, f"Error: {e}"))
            success = False
        finally:
            # 清理测试文件
            try:
                if os.path.exists(test_file_path):
                    os.remove(test_file_path)
                if os.path.exists(os.path.join(self.project_path, "test_table")):
                    os.remove(os.path.join(self.project_path, "test_table"))
            except:
                pass
                
        return success
    
    def run_all_tests(self) -> bool:
        """运行所有测试"""
        print("Starting automated tests for Zig CLI Library")
        print("=" * 50)
        
        tests = [
            self.test_build,
            self.test_unit_tests,
            self.test_performance_tests,
            self.test_main_application,
            self.test_color_functionality,
            self.test_progress_bar_functionality,
            self.test_spinner_functionality,
            self.test_table_functionality,
        ]
        
        results = []
        for test in tests:
            try:
                result = test()
                results.append(result)
                print()
            except Exception as e:
                print(f"  ✗ Test failed with exception: {e}")
                results.append(False)
                print()
        
        # 输出测试总结
        print("=" * 50)
        print("Test Summary:")
        print("=" * 50)
        
        passed = 0
        failed = 0
        
        for name, success, message in self.test_results:
            status = "PASS" if success else "FAIL"
            print(f"{status:4} | {name:25} | {message}")
            if success:
                passed += 1
            else:
                failed += 1
        
        print("=" * 50)
        print(f"Total: {len(self.test_results)} | Passed: {passed} | Failed: {failed}")
        
        if failed == 0:
            print("🎉 All tests passed!")
            return True
        else:
            print(f"❌ {failed} test(s) failed.")
            return False

def main():
    # 获取项目路径
    project_path = os.path.dirname(os.path.abspath(__file__))
    
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
    
    # 创建测试运行器并运行测试
    runner = ZigCLITestRunner(project_path)
    success = runner.run_all_tests()
    
    # 返回适当的退出码
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()