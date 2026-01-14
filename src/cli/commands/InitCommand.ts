import { BaseCommand } from '../BaseCommand';
import { Logger } from '../../core/logging/Logger';

/**
 * InitCommand - Initialize a new project or workspace
 * Sets up project structure, configuration, and initial files
 */
export class InitCommand extends BaseCommand {
    name = 'init';
    description = 'Initialize a new project or workspace';
    examples = [
        'init my-project',
        'init --template typescript',
        'init --force',
    ];

    /**
     * Template types for project initialization
     */
    private templates = {
        typescript: {
            name: 'TypeScript',
            files: [
                { path: 'tsconfig.json', content: this.getTsConfig() },
                { path: 'package.json', content: this.getPackageJson() },
                { path: 'src/index.ts', content: this.getIndexTs() },
                { path: '.gitignore', content: this.getGitignore() },
            ],
        },
        javascript: {
            name: 'JavaScript',
            files: [
                { path: 'package.json', content: this.getPackageJson() },
                { path: 'src/index.js', content: this.getIndexJs() },
                { path: '.gitignore', content: this.getGitignore() },
            ],
        },
        python: {
            name: 'Python',
            files: [
                { path: 'requirements.txt', content: 'pytest>=7.0.0\npytest-cov>=4.0.0' },
                { path: 'src/__init__.py', content: '' },
                { path: 'src/main.py', content: this.getMainPy() },
                { path: '.gitignore', content: this.getPythonGitignore() },
            ],
        },
        rust: {
            name: 'Rust',
            files: [
                { path: 'Cargo.toml', content: this.getCargoToml() },
                { path: 'src/main.rs', content: this.getMainRs() },
                { path: '.gitignore', content: this.getRustGitignore() },
            ],
        },
    };

    /**
     * Get TypeScript configuration
     */
    private getTsConfig(): string {
        return JSON.stringify({
            compilerOptions: {
                target: 'ES2020',
                module: 'commonjs',
                lib: ['ES2020'],
                outDir: './dist',
                rootDir: './src',
                strict: true,
                esModuleInterop: true,
                skipLibCheck: true,
                forceConsistentCasingInFileNames: true,
                resolveJsonModule: true,
            },
            include: ['src/**/*'],
            exclude: ['node_modules', 'dist'],
        }, null, 2);
    }

    /**
     * Get package.json
     */
    private getPackageJson(): string {
        return JSON.stringify({
            name: this.args[0] || 'my-project',
            version: '1.0.0',
            description: 'A new project',
            main: 'dist/index.js',
            types: 'dist/index.d.ts',
            scripts: {
                build: 'tsc',
                test: 'jest',
                lint: 'eslint . --ext .ts',
            },
            keywords: [],
            author: '',
            license: 'MIT',
        }, null, 2);
    }

    /**
     * Get TypeScript index file
     */
    private getIndexTs(): string {
        return `export function main() {
    console.log('Hello, World!');
}

main();
`;
    }

    /**
     * Get JavaScript index file
     */
    private getIndexJs(): string {
        return `function main() {
    console.log('Hello, World!');
}

main();
`;
    }

    /**
     * Get Python main file
     */
    private getMainPy(): string {
        return `def main():
    print("Hello, World!")

if __name__ == "__main__":
    main()
`;
    }

    /**
     * Get Rust main file
     */
    private getMainRs(): string {
        return `fn main() {
    println!("Hello, World!");
}

fn main() {
    main()
}
`;
    }

    /**
     * Get Cargo.toml
     */
    private getCargoToml(): string {
        return `[package]
name = "${this.args[0] || 'my-project'}"
version = "1.0.0"
edition = "2021"

[dependencies]
`;
    }

    /**
     * Get .gitignore
     */
    private getGitignore(): string {
        return `node_modules/
dist/
.env
.DS_Store
*.log
`;
    }

    /**
     * Get Python .gitignore
     */
    private getPythonGitignore(): string {
        return `__pycache__/
*.py[cod]
.env
.venv/
dist/
*.log
`;
    }

    /**
     * Get Rust .gitignore
     */
    private getRustGitignore(): string {
        return `target/
Cargo.lock
.env
.DS_Store
*.log
`;
    }

    /**
     * Execute the init command
     */
    async execute(): Promise<void> {
        const logger = new Logger('InitCommand');
        const projectName = this.args[0];
        const template = this.flags.template || 'typescript';
        const force = this.flags.force;

        logger.info(`Initializing project: ${projectName || 'current directory'}`);
        logger.info(`Template: ${template}`);

        // Check if directory exists
        if (projectName && !force) {
            try {
                await Deno.stat(projectName);
                logger.error(`Directory ${projectName} already exists. Use --force to overwrite.`);
                return;
            } catch {
                // Directory doesn't exist, proceed
            }
        }

        // Create project directory
        const projectDir = projectName || '.';
        if (projectName) {
            await Deno.mkdir(projectName, { recursive: true });
        }

        // Get template
        const templateConfig = this.templates[template as keyof typeof this.templates];
        if (!templateConfig) {
            logger.error(`Unknown template: ${template}`);
            logger.info(`Available templates: ${Object.keys(this.templates).join(', ')}`);
            return;
        }

        // Create files
        logger.info(`Creating ${templateConfig.files.length} files...`);
        for (const file of templateConfig.files) {
            const filePath = `${projectDir}/${file.path}`;
            const dirPath = filePath.substring(0, filePath.lastIndexOf('/'));

            // Create directory if needed
            if (dirPath !== projectDir) {
                await Deno.mkdir(dirPath, { recursive: true });
            }

            // Write file
            await Deno.writeTextFile(filePath, file.content);
            logger.success(`Created: ${file.path}`);
        }

        logger.success(`Project ${projectName || 'initialized'} successfully!`);
        logger.info(`Next steps:`);
        logger.info(`  cd ${projectName || '.'}`);
        logger.info(`  npm install  # or: pip install -r requirements.txt`);
        logger.info(`  npm run build`);
    }
}
