/**
 * @author discordrpc
 * 
 * @example
 * node bundler.js ./src main.luau output.luau
 */
const version = '1.0.0';
const fs = require('fs');
const path = require('path');

/**
 * Bundles all Lua files starting from an entryFile under baseDir.
 *
 * @param {string} baseDir - The base folder
 * @param {string} entryFile - The entry .lua file name
 * @returns {string} A single string containing the bundled Lua code
 */
function bundleLua(baseDir, entryFile) {
  const visited = new Set();
  const modules = {};

  /**
   * Outputs a warning to the console if a type definition
   * is found in a module. This should be done in a
   * dedicated types folder.
   * 
   * @param {string} luaContent - The Lua content
   * @param {string} filePath - The file path
   * 
   * @example
   * ```luau
   * -- These will trigger a warning
   * type MyType = {}
   * export type ExportedType = {}
   * ```
   */
  function warnOnTypeDefinitions(luaContent, filePath) {
    const typeRegex = /(?:^|\s)(export\s+)?type\s+([a-zA-Z0-9_]+)\s*=/gm;

    let match;
    while ((match = typeRegex.exec(luaContent)) !== null) {
      const isExport = !!match[1];
      if (isExport) {
        console.warn(
          `\x1b[33m[WARN] \x1b[0mFound exported type \x1b[32m'${match[2]}' \x1b[0min module: \x1b[34m${filePath}\x1b[0m`
        );
        continue;
      } else {
        console.warn(
          `\x1b[33m[WARN] \x1b[0mFound type \x1b[32m'${match[2]}' \x1b[0min module: \x1b[34m${filePath}\x1b[0m`
        );
      }
    }
  }

  /**
   * Resolves a module path relative to the current file.
   * 
   * @param {string} baseDir - The base directory
   * @param {string} currentFilePath - The current file path
   * @param {string} requiredPath - The required path
   * @returns {string} The resolved module path
   */
  function resolveModulePath(baseDir, currentFilePath, requiredPath) {
    const currentDir = path.dirname(currentFilePath);
    let absolute = path.resolve(currentDir, requiredPath);

    const extension = path.extname(absolute).toLowerCase();
    if (!extension) {
      if (fs.existsSync(absolute + '.lua')) {
        absolute += '.lua';
      } else if (fs.existsSync(absolute + '.luau')) {
        absolute += '.luau';
      } else {
        throw new Error(`Cannot find module \x1b[33m'${requiredPath}' \x1b[0m(at \x1b[34m${path.resolve(currentDir, currentFilePath)}\x1b[0m)`);
      }
    } else {
      if (!fs.existsSync(absolute)) {
        throw new Error(`Cannot find module \x1b[33m'${requiredPath}' \x1b[0m(at \x1b[34m${path.resolve(currentDir, currentFilePath)}\x1b[0m)`);
      }
    }

    return path.relative(baseDir, absolute).replace(/\\/g, '/');
  }

  /**
   * Parses and transforms LUA content.
   * - Replaces require(...) calls with import(...) calls
   * - Detects submodules
   * 
   * @param {string} luaContent - The Lua content
   * @param {string} currentFilePath - The current file path
   * @returns {object} The new content and submodules
   */
  function parseAndTransform(luaContent, currentFilePath) {
    const subModules = [];

    const requirePattern = /\brequire\s*\(\s*([^)]*)\)/g;
    const newContent = luaContent.replace(requirePattern, (_, arg) => {
      const quotedMatch = arg.match(/^["']([^"']+)["']$/);
      if (quotedMatch) {
        const requiredPath = quotedMatch[1];
        const resolvedModule = resolveModulePath(baseDir, currentFilePath, requiredPath);

        subModules.push(resolvedModule);
        return `import("${resolvedModule}")`;
      } else {
        return `import(${arg})`;
      }
    });

    return { newContent, subModules };
  }

  /**
   * Loads a module and its submodules. If a module is already loaded,
   * it will be skipped. If a circular import is detected, an error
   * is thrown.
   * 
   * @param {string} moduleName - The canonical module name
   * @param {string[]} stack - The stack of modules
   * @param {string} previousPath - The previous path
   */
  function loadModule(moduleName, stack = [], previousPath) {
    const modulePath = path.resolve(baseDir, moduleName);

    if (stack.includes(modulePath)) {
      throw new Error(`Circular import detected: \x1b[33m'${moduleName}' \x1b[0m(at \x1b[34m${previousPath}\x1b[0m)`);
    }
    if (visited.has(modulePath)) return;

    stack.push(modulePath);

    let luaContent;
    try {
      luaContent = fs.readFileSync(modulePath, 'utf8');
    } catch (err) {
      throw new Error(`Could not read file at \x1b[34m${modulePath} \x1b[0m${err.message}`);
    }

    warnOnTypeDefinitions(luaContent, moduleName);

    const { newContent, subModules } = parseAndTransform(luaContent, modulePath);
    modules[moduleName] = newContent;

    for (const subModule of subModules) {
      loadModule(subModule, stack, modulePath);
    }

    stack.pop();
    visited.add(modulePath);
  }

  const entryPath = path.join(baseDir, entryFile);
  let entryContent;
  try {
    entryContent = fs.readFileSync(entryPath, 'utf8');
  } catch (err) {
    throw new Error(`Could not read file at \x1b[34m${entryPath} \x1b[0m${err.message}`);
  }

  warnOnTypeDefinitions(entryContent, entryFile);

  const { newContent: transformedEntry, subModules: entryImports } =
    parseAndTransform(entryContent, entryPath);

  for (const subModule of entryImports) {
    loadModule(subModule, [], entryPath);
  }

  const now = new Date();
  const dateString = now.toLocaleDateString();
  const timeString = now.toLocaleTimeString();

  const output = [];
  output.push(
    '--',
    `-- LuaBundler v${version}`,
    `-- Bundled on ${dateString} at ${timeString}`,
    '-- @author discordrpc',
    '--',
    '--!nolint',
    'local __BUNDLE = {}',
    ''
  );

  for (const [name, luaSource] of Object.entries(modules)) {
    output.push(
      `__BUNDLE['${name}'] = function()`,
      luaSource,
      'end',
      ''
    );
  }

  output.push(
    'function import(name)',
    '  if __BUNDLE[name] then',
    '    if type(__BUNDLE[name]) == \'function\' then',
    '      local result = __BUNDLE[name]()',
    '      __BUNDLE[name] = result',
    '      return result',
    '    else',
    '      return __BUNDLE[name]',
    '    end',
    '  else',
    '    error(\'Module "\' .. name .. \'" not found in bundle\')',
    '  end',
    'end',
    ''
  );

  output.push(
    'function game_require(module, callback)',
    '  setthreadidentity(2)',
    '  local imported = require(module)',
    '  if typeof(callback) == \'function\' and imported ~= nil then',
    '    callback(imported)',
    '  end',
    '  setthreadidentity(7)',
    '  if imported == nil then',
    '    error(\'Failed to require game module "\' .. module .. \'"\')',
    '  else',
    '    return imported',
    '  end',
    'end',
    ''
  );

  output.push('-- Entry point', transformedEntry);

  return output.join('\n');
}

/**
 * CLI usage
 * @param {string} baseDir
 * @param {string} entryFile
 * @param {string} outputFile
 * 
 * @example
 * node bundler.js ./src main.luau output.luau
 */
if (process.argv.length < 5) {
  console.error(`\x1b[31m[ERROR] \x1b[0mIncorrect usage
    
\x1b[33mnode \x1b[0mbundler.js \x1b[34m<baseDir> <entryFile> <outputFile>
    \x1b[33m<baseDir>\x1b[90m - The base directory to start bundling from (e.g. ./src)
    \x1b[33m<entryFile>\x1b[90m - The entry file (e.g. main.luau)
    \x1b[33m<outputFile>\x1b[90m - The output file (e.g. ./bundle/output.luau)\x1b[0m`
  );
  process.exit(1);
}

const baseDir = process.argv[2];
const entryFile = process.argv[3];
const outputFile = process.argv[4];

try {
  const bundledLua = bundleLua(baseDir, entryFile);
  fs.writeFileSync(outputFile, bundledLua, 'utf8');
  console.log(`\x1b[32m[SUCCESS] \x1b[0mBundled Lua code written to \x1b[34m${outputFile}\x1b[0m`);
} catch (err) {
  console.error(`\x1b[31m[ERROR] \x1b[0m${err.message}`);
  process.exit(1);
}
