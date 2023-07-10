## Flag Change

1. Change flag in management tool for staging
2. This triggers rebuild of staging templates `make staging`
3. Validate that change deploys and has desired output
4. Change flag in management tool for production
5. This triggers rebuild of production templates `make production`
6. Change deployed to production

## Template Change

1. Make change in templates in staging and push to branch
2. Create PR to merge template changes
3. Merge PR and trigger staging rebuild `make staging`
4. Validate that change deploys and has desired output