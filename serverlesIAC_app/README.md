# Serverless WEBAPP Using IAC(infrastructure as code)

Tools & Requirements:

  Terraform,
  
  Python,

  Ansible(for this you want WSL for windows),
  
  [WSL(window subsystem for linux)](https://learn.microsoft.com/en-us/windows/wsl/install#prerequisites)
  
  AWS account,
  
  Vscode(any IDE),
  
  Postman(Optional).


# How to start:
1. Download the requirements and set environment variables acc to that.
2. Go to VS code and switch to WSL Envinornment.
3. Downlaod ansible, terraform and recheck the version.
4. Add folders & files to VScode.
5. And then download the plugins needed in vscode
6. Once check the terraform code acc to ur aws account and credientals and region.
7. Move to ansible folder and the command<"ansible-playbook -i inventory.ini ansible.yml">
8. And then check the resource that are created in AWS console.
9. Go to API and deploy the resource in "DEV" ,it will generate the url .
10. Use that url and check it in postman using (/postdetails).
11. Add this url in [index.html] and then again run the playbook.
12. if you get any error while ruuning the playbook agian delete the (tfplan)file that was generated(then run the playbook).
13. After sucessfully excuetion  of playbook go to S3 and acess the (static)url .
14. Post the details (ignore the changes of ui)
15. Go to dynamodb and see the entries what u posted in web page.
  
