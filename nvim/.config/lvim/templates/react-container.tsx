import {Theme, withStyles} from '@material-ui/core';
import React from 'react';
import {connect} from 'react-redux';
import {Dispatch} from 'redux';
import {IState, ThunkDispatch} from 'store';

const styles = (theme: Theme) => ({
  rootContainer: {
    background: theme.palette.background.paper,
  },
});

interface OwnProps {
  classes: any;
  theme: Theme;
}

interface StateProps {}

const mapStateToProps = (state: IState): StateProps => ({});

interface DispatchProps {}

const mapDispatchToProps = (
  dispatch: Dispatch & ThunkDispatch,
): DispatchProps => ({});

type Props = StateProps & DispatchProps & OwnProps;

export const MachineInfo = (props: Props) => {
  return <div>Hellow from InstancesMap</div>;
};

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(withStyles(styles, {withTheme: true})(MachineInfo));

