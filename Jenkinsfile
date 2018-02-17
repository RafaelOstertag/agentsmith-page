properties([buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5')), pipelineTriggers([githubPush(), pollSCM('')])])

node("master") {
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
	    sshagent(['16bce2a7-451d-4be5-82cb-68efab430517']) {
		sh "env REMOTE_USER=agentsmith-deploy REMOTE_HOST=eventhorizon.dmz.kruemel.home REMOTE_BASE=/var/www/jails/agentsmith/usr/local/www/apache24/data scripts/deploy.sh"
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
