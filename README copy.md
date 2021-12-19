Commands used:

1. Use Application Default Credentials (ADC):
`gcloud auth application-default login`

1. Create a new GCP Project:
`gcloud projects create <PROJECT_ID>`

1. List all GCP Projects:
`gcloud projects list`

1. Set active Project:
`gcloud config set project <PROJECT_ID>`

1. Use Service Account Credentials:
```
gcloud iam service-accounts create prod-svc
gcloud projects add-iam-policy-binding unifi-controller-kyle --member="serviceAccount:prod-svc@unifi-controller-kyle.iam.gserviceaccount.com" --role="roles/owner"
gcloud iam service-accounts keys create prod-svc-creds.json --iam-account=prod-svc@unifi-controller-kyle.iam.gserviceaccount.com
```

1. Set GCP Credentials:
`set GOOGLE_APPLICATION_CREDENTIALS=C:\Users\Kyle\AppData\Roaming\gcloud\application_default_credentials.json`

1. Set ssh username (Optional):
`set TF_VAR_username=kyle`

1. Run init
`terraform init`

1. Run Validate
`terraform validate`

1. Run Apply
`terraform apply`
