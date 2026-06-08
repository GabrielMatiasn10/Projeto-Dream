14-Bis - Sistema de Gerenciamento de Check-In ✈️

Este repositório contém a documentação, os requisitos e o guia de implementação para o MVP do sistema de gerenciamento de Check-In solicitado pelo conglomerado de aviação Santos Dummont, baseado nas especificações do documento "Desafio Check-In 3.pdf".

##  Contexto & Fluxo de Uso
O sistema foi projetado para ser operado de forma ágil por agentes de viagens durante atendimentos telefônicos ou presenciais:
1. **Verificação**: O agente confirma se o cliente possui uma conta (`Account`). Caso não possua, realiza o cadastro imediatamente.
2. **Agendamento**: O agente cria o registro de Check-In vinculado à conta do cliente com os dados do voo.
3. **Efetivação**: No dia do voo, o agente valida os dados do passageiro e clica no botão dedicado para realizar o check-in, consolidando a viagem no sistema.

---

## Estrutura da Equipe (4 Integrantes)
Para otimizar o desenvolvimento na plataforma Salesforce e paralelizar as tarefas, o projeto está dividido em 4 frentes de trabalho claras:

* **Dev 1: Data Architect & Security** (Foco em Modelagem de Dados, Perfis e Permissões)
* **Dev 2: UI/UX Specialist** (Foco no Aplicativo, Layouts e Flexi Pages)
* **Dev 3: Business Logic Guard** (Foco em Regras de Validação, Restrições e Botões de Ação)
* **Dev 4: Automation Engineer** (Foco em Fluxos de Automação e Disparos de E-mail)

---

##  Passo a Passo de Implementação por Responsabilidade

###  Dev 1: Modelagem de Dados e Usuários
> **Objetivo:** Construir a fundação estrutural e a camada de segurança de acessos do sistema.

* **Passo 1: Objeto Customizado Check-In**
  * Criar o objeto `Check_In__c` com os seguintes campos:
    * `Cliente__c`: Relacionamento de Lookup para `Account`.
    * `Status__c`: Picklist (Valores: `Novo`, `Realizado`, `Não Realizado`).
    * `Aeroporto_Check_In__c` e `Aeroporto_Destino__c`: Picklist contendo as siglas: GRU, GIG, BSB, CWB, SSA, CNF, BEL, FLN, NAT, CGH, POA, MAO, REC, FOR, CGB.
    * `Codigo_Voo__c`: Texto.
    * `Horario_Voo__c`: Data/Hora.
    * `Horario_Check_In__c`: Data/Hora.
    * `Numero_Assento__c`: Texto.
* **Passo 2: Extensão do Objeto Account**
  * Adicionar novos campos customizados em `Account`:
    * `Numero_Check_Ins_Ano__c`: Número.
    * `Numero_Check_Ins_Totais__c`: Número.
    * `CPF__c`: Texto.
    * `Data_Nascimento__c`: Data.
    * `Necessita_Cuidados_Especiais__c`: Checkbox (Representa se o cliente tem necessidade de cuidado extra).
* **Passo 3: Configuração de Segurança e Usuários**
  * Clonar o perfil nativo `Minimum Access` para criar o perfil **Agente de Viagens**.
  * Conceder ao perfil acesso completo (Visualização, Criação e Edição) para os objetos `Account` e `Check-In`.
  * Criar usuários de teste com este novo perfil para validação das entregas.

### Dev 2: Interface e Experiência do Usuário (UI/UX)
> **Objetivo:** Garantir um ambiente de trabalho limpo, focado e de alta produtividade para os agentes.

* **Passo 1: Aplicativo Customizado 14-Bis**
  * Criar o Lightning App chamado **14-Bis**.
  * Incluir no menu de navegação apenas o necessário para o fluxo: guias de `Accounts` e `Check-Ins`.
  * Definir este aplicativo como padrão (*default*) para o perfil de Agente de Viagens.
* **Passo 2: Organização de Layouts de Página (Page Layouts)**
  * Organizar os campos nos layouts tradicionais de `Account` e `Check-In` agrupando informações de forma lógica e legível para consultas rápidas em chamadas.
* **Passo 3: Customização de Flexi Pages (Lightning Record Pages)**
  * Desenhar as páginas Lightning organizando os componentes para destacar informações críticas (como o alerta de Cuidados Especiais na Account).
* **Passo 4: Criação de Check-In Facilitada**
  * Criar uma Ação Rápida (Quick Action) do tipo "Criar Registro" dentro do objeto `Account` para permitir que o agente crie um Check-In diretamente da tela do cliente.

###  Dev 3: Regras de Negócio e Validações
> **Objetivo:** Proteger a integridade dos dados e impedir falhas operacionais humanas.

* **Passo 1: Validação de CPF**
  * Criar uma Regra de Validação (Validation Rule) em `Account` para assegurar que o CPF seja preenchido no formato correto, aceitando com ou sem pontuações estruturais.
* **Passo 2: Trava de Horário do Check-In**
  * Criar uma Regra de Validação em `Check_In__c` que impeça que o check-in seja realizado caso o `Horario_Check_In__c` seja superior ao `Horario_Voo__c`.
* **Passo 3: Restrição de Edição Retroativa**
  * Criar uma Regra de Validação em `Check_In__c` para impedir a alteração ou edição de registros cujo status esteja definido como `Não Realizado`.
* **Passo 4: Botão Operacional "Realizar Check-In"**
  * Criar um botão ou ação rápida no objeto `Check_In__c` que mude automaticamente o `Status__c` para `Realizado` e preencha o `Horario_Check_In__c` com o timestamp exato do momento da execução.

###  Dev 4: Automações e Inteligência
> **Objetivo:** Automatizar processos em segundo plano para otimizar o tempo e engajar clientes.

* **Passo 1: Atualização Automática de Contadores na Conta**
  * Desenvolver um fluxo automatizado (Record-Triggered Flow) disparado sempre que um Check-In for alterado para `Realizado`. 
  * O fluxo deve recalcular o `Numero_Check_Ins_Totais__c` e o `Numero_Check_Ins_Ano__c` (contabilizando apenas os check-ins feitos dentro do ano corrente).
* **Passo 2: Rotina de Expirados (Não Realizados)**
  * Criar um Fluxo Agendado (Scheduled Flow) periódico para varrer o sistema. Se um Check-In ainda estiver com status `Novo` e o `Horario_Voo__c` já tiver passado, o sistema deve atualizar o status automaticamente para `Não Realizado`.
* **Passo 3: Régua de Relacionamento e Fidelidade (Extra)**
  * Configurar um Email Alert via Flow para disparar uma mensagem de agradecimento com cupom de desconto exclusivo sempre que o cliente atingir exatamente as marcas históricas ou anuais de **10, 50 ou 100** Check-Ins Totais.

---

##  Estratégia de Testes Integrados (QA)
Antes de consolidar a entrega final para o Santos Dummont, a equipe deve realizar os testes simulando o dia a dia do agente:
1. Cadastrar uma conta simulando erros de CPF para validar a trava do Dev 3.
2. Criar um check-in usando o botão rápido na Account estruturado pelo Dev 2.
3. Validar se o botão "Realizar Check-In" atualiza o status e os horários instantaneamente.
4. Conferir se os contadores numéricos na Account subiram corretamente e se o e-mail de fidelidade foi gerado ao atingir os gatilhos (10, 50 ou 100).