properties([buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5')), pipelineTriggers([githubPush(), pollSCM('')])])

node("odin") {
    try {
	stage("checkout") {
	    checkout scm
	}

	stage("clean") {
	    sh "gmake clean"
	}

	stage("build") {
	    sh "gmake all"
	}

	stage("deploy") {
	    sshagent(['897482ed-9233-4d56-88c3-254b909b6316']) {
		sh "env REMOTE_USER=ec2-deploy REMOTE_HOST=ec2-52-29-59-221.eu-central-1.compute.amazonaws.com REMOTE_BASE=/data/www/agentsmith.guengel.ch/ software-page-utils/deploy.sh"
	    }
	}
	currentBuild.result = 'SUCCESS'
    } catch (e) {
	currentBuild.result = 'FAILURE'
    } finally {
	emailext body: '''$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS:

Check console output at $BUILD_URL to view the results.''', recipientProviders: [[$class: 'DevelopersRecipientProvider']], subject: '[jenkins.guengel.ch] $PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', to: 'rafi@guengel.ch'
    }
}
