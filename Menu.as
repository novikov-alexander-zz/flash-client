package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	public class Menu extends MovieClip {
		// game default settings
		private var game: Game;
/*
		public function getShMass(): int {
			return showMass;
		}
		public function getShNick(): int {
			return showNick;
		}
		public function getShSkins(): int {
			return showSkins;
		}
		public function getIsFFA(): int {
			return isFFA;
		}
		public function getThemeNo(): int {
			return themeNo;
		}
		public function getNickName(): String {
			return nickName;
		}*/
		public function Menu(_game: Game) {
			super();
			this.stop();
			game = _game;
			startBtn.textField.setTextFormat(new TextFormat("Verdana",50));
			startBtn.addEventListener(MouseEvent.CLICK, startBtnHandler); // frame 1 menu
			settingsBtn.addEventListener(MouseEvent.CLICK, settingsBtnHandler); // frame 1 menu
			helpBtn.addEventListener(MouseEvent.CLICK, helpBtnHandler); // frame 1 menu
			recordsBtn.addEventListener(MouseEvent.CLICK, recordsBtnHandler); // frame 1 menu
		}

		private function startBtnHandler(e: MouseEvent): void {
			gotoAndStop(2); // start game
			ffaBtn.enabled = true;
			teamsBtn.enabled = true;
			exitBtn2.addEventListener(MouseEvent.CLICK, exitBtnHandler); // frame 2 start
			ffaBtn.addEventListener(MouseEvent.CLICK, ffaBtnHandler); // frame 2 start
			teamsBtn.addEventListener(MouseEvent.CLICK, teamsBtnHandler); // frame 2 start

		}

		private function ffaBtnHandler(e: MouseEvent): void {
			game.isFFA = 1;
			ffaBtn.enabled = false;
			teamsBtn.enabled = false;
			game.goPlay();
			stage.focus = game;
		}

		private function teamsBtnHandler(e: MouseEvent): void {
			game.isFFA = 0;
			gotoAndStop(4); // help
			exitBtn4.addEventListener(MouseEvent.CLICK, exitBtnHandler); // frame 4
		}

		private function settingsBtnHandler(e: MouseEvent): void {
			gotoAndStop(3); // settings
			exitBtn3.addEventListener(MouseEvent.CLICK, exitBtnHandler3); // frame 3
			nickNameFld.maxChars = 16;
			nickNameFld.text = game.nickName;
			showMassChb.selected = game.showMass > 0;
			showNickChb.selected = game.showNick > 0;
			showSkinsChb.selected = game.showSkins > 0;
			themeNoSelector.value = game.themeNo;
			stage.focus = nickNameFld;
		}

		private function helpBtnHandler(e: MouseEvent): void {
			gotoAndStop(4); // help
			exitBtn4.addEventListener(MouseEvent.CLICK, exitBtnHandler); // frame 4
		}

		private function recordsBtnHandler(e: MouseEvent): void {
			gotoAndStop(5); // settings
			exitBtn5.addEventListener(MouseEvent.CLICK, exitBtnHandler); // frame 5
		}

		public function exitBtnHandler(e: MouseEvent): void {
			gotoAndStop(1); // menu
			startBtn.addEventListener(MouseEvent.CLICK, startBtnHandler); // frame 1 menu
			settingsBtn.addEventListener(MouseEvent.CLICK, settingsBtnHandler); // frame 1 menu
			helpBtn.addEventListener(MouseEvent.CLICK, helpBtnHandler); // frame 1 menu
			recordsBtn.addEventListener(MouseEvent.CLICK, recordsBtnHandler); // frame 1 menu
		}

		private function exitBtnHandler3(e: MouseEvent): void {
			game.nickName = nickNameFld.text;
			game.themeNo = themeNoSelector.value;
			game.showMass = int(showMassChb.selected);
			game.showNick = int(showNickChb.selected);
			game.showSkins = int(showSkinsChb.selected);
			gotoAndStop(1); // menu
			startBtn.addEventListener(MouseEvent.CLICK, startBtnHandler); // frame 1 menu
			settingsBtn.addEventListener(MouseEvent.CLICK, settingsBtnHandler); // frame 1 menu
			helpBtn.addEventListener(MouseEvent.CLICK, helpBtnHandler); // frame 1 menu
			recordsBtn.addEventListener(MouseEvent.CLICK, recordsBtnHandler); // frame 1 menu
		}

		public function startNew(): void {
			game.addChild(this);
			gotoAndStop(1); // menu
			startBtn.addEventListener(MouseEvent.CLICK, startBtnHandler); // frame 1 menu
			settingsBtn.addEventListener(MouseEvent.CLICK, settingsBtnHandler); // frame 1 menu
			helpBtn.addEventListener(MouseEvent.CLICK, helpBtnHandler); // frame 1 menu
			recordsBtn.addEventListener(MouseEvent.CLICK, recordsBtnHandler); // frame 1 menu
		}
	}
}