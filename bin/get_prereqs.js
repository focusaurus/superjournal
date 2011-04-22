var path = require('path');
var fs = require('fs');
var packagePath = path.join(__dirname, "../package.json");
var jsonData = fs.readFileSync(packagePath, 'utf8');
var info = JSON.parse(jsonData);
var deps = info.dependencies;
for(var property in deps) {
  console.log(property);
}
