# Learning terraform

> you ahve to be in the root directory [application/](./application/) to run terraform commands

## format files

```sh
terraform fmt -recursive
```

## Initialize

```sh
terraform init
```

## plan

```sh
terraform plan
```

## apply (will plan again to create/update while applying)

```sh
terraform apply
```

## destroy (will plan again to destroy while applying)

```sh
terraform destroy
```

## plan with output

```sh
terraform plan -out check.tfplan
```

## plan to destroy with output

```sh
terraform plan --destroy -out check.tfplan
```

## apply with output (will apply exactly what was planned in the .tflan file create/update/destroy)

```sh
terraform apply check.tfplan
```
