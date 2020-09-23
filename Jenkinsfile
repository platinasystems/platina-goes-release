#!groovy

import groovy.transform.Field

@Field String email_to = 'kph@platinasystems.com'
@Field String email_from = 'jenkins-bot@platinasystems.com'
@Field String email_reply_to = 'no-reply@platinasystems.com'

pipeline {
    agent any
    environment {
	GOPATH = "$WORKSPACE/go-pkg"
	HOME = "$WORKSPACE"
    }
    stages {
	stage('Pre-clean') {
	    steps {
		sh 'make clean'
	    }
	}
	stage('Checkout') {
	    steps {
		echo "Running build #${env.BUILD_ID} on ${env.JENKINS_URL} GOPATH ${GOPATH}"
		sshagent(credentials: ['570701f7-c819-4db2-bd31-a0da8a452b41']) {
		    sh 'rm -rf .gnupg ; ln -s ../../.gnupg'
		    sh 'git config --global url.git@github.com:.insteadOf "https://github.com/"'
		    sh 'git config --global user.email "jenkins@platinasystems.com"'
		    sh 'git config --global user.name "Jenkins"'
		    sh 'git config --global user.signingkey 3718F263B7F1AEF2'
		    sh 'git submodule init'
		    sh 'git submodule update -r --remote'
		}
	    }
	}

	stage('Build') {
	    steps {
		sshagent(credentials: ['570701f7-c819-4db2-bd31-a0da8a452b41']) {
			sh 'make'
		}
	    }
	}
    }


    post {
	success {
	    archiveArtifacts artifacts: '*.deb,*.zip,*.changes,*.buildinfo,*.cpio.xz'
	    mail body: "PLATINA-GOES-RELEASE ${env.BRANCH_NAME} build ok: ${env.BUILD_URL}\n",
		from: email_from,
		replyTo: email_reply_to,
		subject: "PLATINA-GOES-RELEASE ${env.BRANCH_NAME} build ok",
		to: email_to
	}
	failure {
	    //cleanWs()
	    mail body: "PLATINA-GOES-RELEASE ${env.BRANCH_NAME} build error: ${env.BUILD_URL}",
		from: email_from,
		replyTo: email_reply_to,
		subject: "PLATINA-GOES-RELEASE ${env.BRANCH_NAME} BUILD FAILED",
		to: email_to
	}
    }
}
