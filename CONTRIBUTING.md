# Contributing to Cloud-Based Learning Platform

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the project.

## Getting Started

### Development Setup

1. **Fork and Clone**
```bash
git clone https://github.com/your-username/cloud-computing-project-full-implementation.git
cd cloud-computing-project-full-implementation
```

2. **Setup Local Environment**
```bash
./scripts/setup-local.sh
docker-compose up -d
```

3. **Create Feature Branch**
```bash
git checkout -b feature/your-feature-name
```

## Development Workflow

### Code Style

- **Python**: Follow PEP 8
- **Terraform**: Use terraform fmt
- **Docker**: Follow best practices for multi-stage builds

```bash
# Format Python code
black services/*/src/**/*.py

# Format Terraform
terraform fmt -recursive infrastructure/

# Lint Python
pylint services/*/src/**/*.py
```

### Testing

```bash
# Run unit tests
pytest services/tts-service/tests/

# Run integration tests
pytest tests/integration/

# Run all tests
pytest
```

### Commit Messages

Use conventional commits:

```
feat: add new TTS voice option
fix: resolve S3 upload timeout issue
docs: update AWS setup guide
refactor: optimize Kafka producer
test: add unit tests for chat service
```

## Pull Request Process

1. **Update Documentation**
   - Update README.md if needed
   - Add/update API documentation
   - Update CHANGELOG.md

2. **Run Tests**
```bash
# Ensure all tests pass
pytest

# Check code quality
pylint services/*/src/
```

3. **Submit PR**
   - Provide clear description
   - Reference related issues
   - Add screenshots if UI changes
   - Request review from maintainers

4. **PR Checklist**
   - [ ] Tests pass
   - [ ] Documentation updated
   - [ ] Code follows style guide
   - [ ] No merge conflicts
   - [ ] Commits are clean

## Project Structure

```
services/          # Microservices
├── tts-service/
│   ├── src/       # Source code
│   ├── tests/     # Tests
│   └── Dockerfile
infrastructure/    # Terraform IaC
kubernetes/        # K8s manifests
docs/             # Documentation
scripts/          # Helper scripts
```

## Adding a New Service

1. **Create Service Directory**
```bash
mkdir -p services/new-service/{src,tests,config}
```

2. **Create Dockerfile**
```dockerfile
FROM python:3.11-slim
# ... standard structure
```

3. **Add to docker-compose.yml**
```yaml
new-service:
  build: ./services/new-service
  ports:
    - "8006:8006"
```

4. **Create Terraform Module**
```hcl
# infrastructure/modules/new-service/
```

5. **Add Documentation**
```markdown
# docs/services/NEW-SERVICE.md
```

## Code Review Guidelines

### For Reviewers

- Check for security issues
- Verify tests are comprehensive
- Ensure documentation is updated
- Look for performance implications
- Verify error handling

### For Contributors

- Respond to feedback promptly
- Make requested changes
- Keep PR scope focused
- Rebase if needed

## Security

- Never commit secrets
- Use AWS Secrets Manager
- Follow OWASP guidelines
- Report security issues privately

## Questions?

- Open a discussion on GitHub
- Check existing issues
- Review documentation

## License

By contributing, you agree that your contributions will be licensed under the project's license.
