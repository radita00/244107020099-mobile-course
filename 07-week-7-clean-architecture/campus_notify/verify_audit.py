import os
import re

workspace = r"d:\Repository\my_first_app\244107020099-mobile-course\07-week-7-clean-architecture\campus_notify"

def scan_files(paths, pattern):
    results = []
    regex = re.compile(pattern)
    for p in paths:
        full_p = os.path.join(workspace, p)
        if not os.path.exists(full_p):
            continue
        for root, _, files in os.walk(full_p):
            for file in files:
                if file.endswith('.dart'):
                    file_path = os.path.join(root, file)
                    rel_path = os.path.relpath(file_path, workspace)
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        for line_no, line in enumerate(f, 1):
                            if regex.search(line):
                                results.append(f"{rel_path}:{line_no} -> {line.strip()}")
    return results

print("=== 1. Presentation steril dari data mentah ===")
res1 = scan_files([
    os.path.join("lib", "features", "auth", "presentation"),
    os.path.join("lib", "features", "announcements", "presentation"),
    os.path.join("lib", "pages"),
], r"Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode")
if res1:
    for r in res1: print(r)
else:
    print("HASIL: 0 pelanggaran (BERSIH - LOLOS)")

print("\n=== 2. Domain steril dari framework & package ===")
res2 = scan_files([
    os.path.join("lib", "features", "auth", "domain"),
    os.path.join("lib", "features", "announcements", "domain"),
    os.path.join("lib", "features", "notes", "domain"),
    os.path.join("lib", "core"),
], r"import\s+['\"]package:(flutter|dio|sqflite|firebase)")
if res2:
    for r in res2: print(r)
else:
    print("HASIL: 0 pelanggaran (BERSIH - LOLOS)")

print("\n=== 3. Instansiasi manual (DI bocor di presentation) ===")
res3 = scan_files([
    os.path.join("lib", "features", "auth", "presentation"),
    os.path.join("lib", "features", "announcements", "presentation"),
    os.path.join("lib", "pages"),
], r"Repository\(|Dio\(BaseOptions")
if res3:
    for r in res3: print(r)
else:
    print("HASIL: 0 pelanggaran (BERSIH - LOLOS)")
