# Build Image
- docker build -t go .

# Configure git and gitlab
### 0. **Create repository**
 First, create the repository and then the runners 
 https://gitlab.com/ci-group3343642/go/-/settings/ci_cd#js-runners-settings
git config --global --list
git config --local user.name "Your Name"
git config --local user.email "your_email@example.com"

### 1. **Check for Existing SSH Key**
First, check if you already have an SSH key on your machine.

Run the following command to check if an SSH key exists:
```bash
ls -al ~/.ssh
```
You should see files like `id_rsa` and `id_rsa.pub` (or another pair of `.pub` files). If you don’t have any, you’ll need to generate a new SSH key.

### 2. **Generate a New SSH Key (if needed)**
If no SSH keys are found, generate a new one by running:
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```
Follow the prompts to save the key in the default location (`~/.ssh/id_rsa`). You can press Enter to skip adding a passphrase unless you want extra security.

### 3. **Add Your SSH Key to the SSH Agent**
To use the generated SSH key, you need to add it to your SSH agent:

Start the SSH agent:
```bash
eval "$(ssh-agent -s)"
```

Then add your SSH private key:
```bash
ssh-add ~/.ssh/id_rsa
```

### 4. **Add SSH Key to GitLab**
Now, add your public SSH key to GitLab:

1. Copy the public key to your clipboard:
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```
2. Go to GitLab and log in to your account.
3. Navigate to **Preferences** -> **SSH Keys** (or click [here](https://gitlab.com/-/user_settings/ssh_keys)).
4. Paste the copied key in the **Key** field and give it a **Title**.
5. Click **Add key**.

### 5. **Check SSH Configuration**
Make sure your `~/.ssh/config` file has the correct settings (or create one if it doesn't exist):

```bash
Host gitlab.com
  HostName gitlab.com
  User git
  IdentityFile ~/.ssh/id_rsa
```

### 6. **Test SSH Connection**
Now, test if you can successfully connect to GitLab via SSH:
```bash
ssh -T git@gitlab.com
```
You should see a message like:
```
Welcome to GitLab, @yourusername!
```

### 7. **Push to GitLab**
Finally, try pushing to your GitLab repository again:
```bash
git push --set-upstream origin main
```

## Create Role
- aws iam create-role \
  --role-name lambda-ex \
  --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'
- aws iam create-role \
  --role-name lambda-ex \
  --assume-role-policy-document file://trust-policy.json
- aws iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole