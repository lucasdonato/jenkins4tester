//configurações de cores para as notificações slack
def COLOR_MAP = ['SUCCESS': 'good', 'FAILURE': 'danger', 'UNSTABLE': 'danger', 'ABORTED': 'danger']

pipeline {
  agent {
    docker {
        image "ruby:alpine"
        args "--network=skynet"
    }
  }
  stages {
    stage("Build") {
      steps {
        sh "chmod +x build/alpine.sh"
        sh "./build/alpine.sh"
        sh "gem install bundler -v 2.0.2"
        sh "bundle install"
        sh "bundle update"
      }
    }
    stage("Test") {
      steps {
           //mensagem disparada antes da execução dos testes..
              //  slackSend channel: "#automacao-de-testes",
             //           color: 'good',
                 //       message: " Iniciando execucao do testes..\n Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"
        sh "bundle exec cucumber -p ci"
      }
      post {
        always {
          junit 'log/*.xml'   
          //configurações do plugin de relatório
                    cucumber failedFeaturesNumber: -1, failedScenariosNumber: -1, failedStepsNumber: -1, fileIncludePattern: '**/*.json', jsonReportDirectory: 'log', pendingStepsNumber: -1, skippedStepsNumber: -1, sortingMethod: 'ALPHABETICAL', undefinedStepsNumber: -1
                    //configurações do slack
                    slackSend channel: "#automacao-de-testes",
                        color: COLOR_MAP[currentBuild.currentResult],
                        message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n Mais informacoes acesse: ${env.BUILD_URL}"

                        emailext attachLog: true, attachmentsPattern: 'log/report.html', body: 'Relatório final jenkins', replyTo: 'lucaspolimig96@gmail.com', subject: 'Execução Testes Jenkins', to: 'lucaspolimig96@gmail.com'    
        }
      }
    }
  }
}
