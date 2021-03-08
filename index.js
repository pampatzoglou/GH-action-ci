const core = require('@actions/core');
const github = require('@actions/github');

try {
  const helmVersion = core.getInput('helm-version');
  console.log(`helm version: ${helmVersion}!`);

  const helmFileVersion = core.getInput('helmfie-version');
  console.log(`helmfile version: ${helmFileVersion}!`);

  const yqVersion = core.getInput('yq-version');
  console.log(`yq version: ${yqVersion}!`);

  const azVersion = core.getInput('az-version');
  console.log(`az version: ${azVersion}!`); 

} catch (error) {
  core.setFailed(error.message);
}